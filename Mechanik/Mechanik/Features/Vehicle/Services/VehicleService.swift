//
//  VehicleService.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import Foundation
import FirebaseFirestore
import FirebaseStorage

final class VehicleService {
    
    static let shared = VehicleService()
    private init() {}
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let collection = "vehicles"
    
    // MARK: - CREATE VEHICLE
    func createVehicle(_ vehicle: Vehicle) async throws -> String {
        let ref = db.collection(collection).document()
        
        let data: [String: Any] = [
            "id": ref.documentID,
            "businessId": vehicle.businessId,
            "plate": vehicle.plate,
            "brand": vehicle.brand,
            "model": vehicle.model,
            "year": vehicle.year,
            "fuelType": vehicle.fuelType,
            "engineSize": vehicle.engineSize as Any,
            "chassisNo": vehicle.chassisNo as Any,
            "ownerName": vehicle.ownerName,
            "ownerPhone": vehicle.ownerPhone as Any,
            "notes": vehicle.notes as Any,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await ref.setData(data)
        return ref.documentID
    }

    func fetchBrands() async throws -> [VehicleBrand] {
        let snapshot = try await db.collection("brands").getDocuments()

        return snapshot.documents
            .map { document in
                let data = document.data()
                return VehicleBrand(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    logoURL: data["logoUrl"] as? String
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func fetchModels(brandId: String) async throws -> [String] {
        let snapshot = try await db.collection("brands")
            .document(brandId)
            .collection("models")
            .getDocuments()

        return snapshot.documents
            .compactMap { $0.data()["name"] as? String }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    func fetchVehicle(id: String, businessId: String) async throws -> Vehicle? {
        let snapshot = try await db.collection(collection).document(id).getDocument()

        guard snapshot.exists, let data = snapshot.data() else {
            return nil
        }

        let vehicle = Vehicle(
            id: snapshot.documentID,
            businessId: data["businessId"] as? String ?? "",
            plate: data["plate"] as? String ?? "",
            brand: data["brand"] as? String ?? "",
            model: data["model"] as? String ?? "",
            year: Self.intFromFirestore(data["year"]),
            fuelType: data["fuelType"] as? String ?? "",
            engineSize: data["engineSize"] as? String,
            chassisNo: data["chassisNo"] as? String,
            ownerName: data["ownerName"] as? String ?? "",
            ownerPhone: data["ownerPhone"] as? String,
            notes: data["notes"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
        )

        return vehicle.businessId == businessId ? vehicle : nil
    }

    func fetchBrandLogoURL(brandName: String) async throws -> String? {
        let snapshot = try await db.collection("brands")
            .whereField("name", isEqualTo: brandName)
            .limit(to: 1)
            .getDocuments()

        return snapshot.documents.first?.data()["logoUrl"] as? String
    }

    func updateVehicle(id: String, payload: VehicleUpdatePayload) async throws {
        try await db.collection(collection).document(id).updateData([
            "ownerName": payload.ownerName,
            "ownerPhone": payload.ownerPhone as Any,
            "engineSize": payload.engineSize as Any,
            "chassisNo": payload.chassisNo as Any,
            "year": payload.year,
            "fuelType": payload.fuelType,
            "notes": payload.notes as Any,
            "lastUpdated": FieldValue.serverTimestamp()
        ])
    }

    func createJob(_ payload: NewJobPayload) async throws -> String {
        let ref = db.collection("jobs").document()

        let quickJobs: [[String: Any]] = payload.selectedQuickJobs.map { item in
            [
                "name": item.name,
                "brand": item.brand,
                "quantity": item.quantity,
                "unitPrice": item.unitPrice
            ]
        }

        try await ref.setData([
            "businessId": payload.businessId,
            "vehicleId": payload.vehicleId,
            "title": payload.title,
            "category": payload.category as Any,
            "mileage": payload.mileage,
            "notes": payload.notes as Any,
            "laborFee": payload.laborFee,
            "selectedQuickJobs": quickJobs,
            "imageUrls": payload.imageUrls,
            "status": "active",
            "createdAt": FieldValue.serverTimestamp()
        ])

        return ref.documentID
    }

    func uploadJobImages(businessId: String, vehicleId: String, images: [Data]) async throws -> [String] {
        var uploadedURLs: [String] = []

        for (index, data) in images.enumerated() {
            let fileName = "\(Date().timeIntervalSince1970)-\(index).jpg"
            let storageRef = storage.reference(withPath: "businesses/\(businessId)/vehicles/\(vehicleId)/jobs/\(fileName)")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            _ = try await storageRef.putDataAsync(data, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL()
            uploadedURLs.append(downloadURL.absoluteString)
        }

        return uploadedURLs
    }

    func fetchJobs(vehicleId: String, includeCancelled: Bool = false) async throws -> [JobListItem] {
        let snapshot = try await db.collection("jobs")
            .whereField("vehicleId", isEqualTo: vehicleId)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            let rawStatus = data["status"] as? String
            let status = JobStatus(rawValue: rawStatus?.lowercased() ?? "") ?? .active

            if !includeCancelled,
               status == .cancelled {
                return nil
            }

            return JobListItem(
                id: document.documentID,
                vehicleId: vehicleId,
                title: data["title"] as? String ?? "(Basliksiz islem)",
                status: status,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue(),
                category: data["category"] as? String,
                mileage: Self.intFromFirestore(data["mileage"]),
                notes: data["notes"] as? String,
                laborFee: Self.doubleFromFirestore(data["laborFee"]),
                selectedQuickJobs: Self.quickItems(from: data["selectedQuickJobs"]),
                imageUrls: data["imageUrls"] as? [String] ?? []
            )
        }
        .sorted { lhs, rhs in
            let lhsDate = lhs.createdAt ?? .distantPast
            let rhsDate = rhs.createdAt ?? .distantPast
            return lhsDate > rhsDate
        }
    }

    func fetchJobStats(vehicleId: String) async throws -> VehicleJobStats {
        let jobs = try await fetchJobs(vehicleId: vehicleId, includeCancelled: true)

        let activeCount = jobs.filter { $0.status == .active }.count
        let completedCount = jobs.filter { $0.status == .completed }.count
        let totalCount = jobs.filter { $0.status != .cancelled }.count

        return VehicleJobStats(total: totalCount, active: activeCount, completed: completedCount)
    }

    func updateJob(
        id: String,
        title: String,
        notes: String?,
        laborFee: Double,
        selectedQuickJobs: [JobQuickItem],
        imageUrls: [String]
    ) async throws {
        let quickJobs: [[String: Any]] = selectedQuickJobs.map { item in
            [
                "name": item.name,
                "brand": item.brand,
                "quantity": item.quantity,
                "unitPrice": item.unitPrice
            ]
        }

        try await db.collection("jobs").document(id).updateData([
            "title": title,
            "notes": notes as Any,
            "laborFee": laborFee,
            "selectedQuickJobs": quickJobs,
            "imageUrls": imageUrls,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func updateJobStatus(id: String, status: String) async throws {
        try await db.collection("jobs").document(id).updateData([
            "status": status,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // MARK: - FETCH VEHICLES (BY BUSINESS)
    func fetchVehicles(businessId: String) async throws -> [Vehicle] {
        let snapshot = try await db.collection(collection)
            .whereField("businessId", isEqualTo: businessId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Vehicle(
                id: doc.documentID,
                businessId: data["businessId"] as? String ?? "",
                plate: data["plate"] as? String ?? "",
                brand: data["brand"] as? String ?? "",
                model: data["model"] as? String ?? "",
                year: Self.intFromFirestore(data["year"]),
                fuelType: data["fuelType"] as? String ?? "",
                engineSize: data["engineSize"] as? String,
                chassisNo: data["chassisNo"] as? String,
                ownerName: data["ownerName"] as? String ?? "",
                ownerPhone: data["ownerPhone"] as? String,
                notes: data["notes"] as? String,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
            )
        }
        .sorted { lhs, rhs in
            lhs.plate.localizedCaseInsensitiveCompare(rhs.plate) == .orderedAscending
        }
    }

    /// Firestore JS / web often stores numbers as Int64 or Double; plain `as? Int` yields 0.
    private static func intFromFirestore(_ value: Any?) -> Int {
        switch value {
        case let i as Int: return i
        case let i as Int64: return Int(i)
        case let i as UInt64: return Int(i)
        case let d as Double: return Int(d)
        case let n as NSNumber: return n.intValue
        default: return 0
        }
    }

    private static func doubleFromFirestore(_ value: Any?) -> Double? {
        switch value {
        case let d as Double: return d
        case let f as Float: return Double(f)
        case let i as Int: return Double(i)
        case let n as NSNumber: return n.doubleValue
        case let s as String: return Double(s)
        default: return nil
        }
    }

    private static func quickItems(from value: Any?) -> [JobQuickItem] {
        guard let rows = value as? [[String: Any]] else { return [] }

        return rows.compactMap { row in
            guard let name = row["name"] as? String else { return nil }

            return JobQuickItem(
                name: name,
                brand: row["brand"] as? String ?? "",
                quantity: intFromFirestore(row["quantity"]),
                unitPrice: doubleFromFirestore(row["unitPrice"]) ?? 0
            )
        }
    }
    
    // MARK: - DELETE VEHICLE
    func deleteVehicle(id: String) async throws {
        try await db.collection(collection).document(id).delete()
    }
}
