//
//  JobListItem.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import Foundation

struct JobListItem: Identifiable, Codable, Hashable {
    var id: String
    var vehicleId: String
    var title: String
    var status: JobStatus
    var createdAt: Date?
    var updatedAt: Date?
    var category: String?
    var mileage: Int?
    var notes: String?
    var laborFee: Double?
    var selectedQuickJobs: [JobQuickItem]
    var imageUrls: [String]

    var totalAmount: Double {
        let partsTotal = selectedQuickJobs.reduce(0) { $0 + $1.lineTotal }
        return partsTotal + (laborFee ?? 0)
    }
}
