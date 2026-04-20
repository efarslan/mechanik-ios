//
//  VehicleService.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import Foundation
import FirebaseFirestore

final class VehicleService {
    
    static let shared = VehicleService()
    private init() {}
    
    private let db = Firestore.firestore()
    private let collection = "vehicles"
    
    // MARK: - CREATE VEHICLE
    func createVehicle(_ vehicle: Vehicle) async throws -> String {
        let ref = db.collection(collection).document()
        
        var data: [String: Any] = [
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
    
    // MARK: - DELETE VEHICLE
    func deleteVehicle(id: String) async throws {
        try await db.collection(collection).document(id).delete()
    }
}
