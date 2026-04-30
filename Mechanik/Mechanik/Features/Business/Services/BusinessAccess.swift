//
//  BusinessAccess.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//


struct BusinessAccess {
    let businessId: String
    let role: String?

    var canCreateVehicle: Bool {
        role == "owner" || role == "manager"
    }

    var canCreateJob: Bool {
        role == "owner" || role == "manager" || role == "technician"
    }
}