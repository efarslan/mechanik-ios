//
//  Vehicle.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import Foundation

struct Vehicle: Identifiable, Codable {
    
    var id: String
    var businessId: String
    
    var plate: String
    var brand: String
    var model: String
    var year: Int
    
    var fuelType: String
    var engineSize: String?
    
    var chassisNo: String?
    
    var ownerName: String
    var ownerPhone: String?
    
    var notes: String?
    
    var createdAt: Date?
}
