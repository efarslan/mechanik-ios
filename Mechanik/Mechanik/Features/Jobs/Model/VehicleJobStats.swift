//
//  VehicleJobStats.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import Foundation

struct VehicleJobStats {
    let total: Int
    let active: Int
    let completed: Int
}

struct VehicleUpdatePayload {
    let ownerName: String
    let ownerPhone: String?
    let engineSize: String?
    let chassisNo: String?
    let year: Int
    let fuelType: String
    let notes: String?
}

struct JobQuickItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var brand: String
    var quantity: Int
    var unitPrice: Double

    var lineTotal: Double {
        Double(quantity) * unitPrice
    }
}

struct NewJobPayload {
    let businessId: String
    let vehicleId: String
    let title: String
    let category: String?
    let mileage: Int
    let notes: String?
    let laborFee: Double
    let selectedQuickJobs: [JobQuickItem]
    let imageUrls: [String]
}


