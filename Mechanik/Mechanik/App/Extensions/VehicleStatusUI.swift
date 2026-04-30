//
//  VehicleStatusUI.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

extension String {

    var jobStatusColor: Color {
        switch lowercased() {
        case "active":
            return .green

        case "completed", "done":
            return Color(
                red: 0.94,
                green: 0.75,
                blue: 0.20
            )

        case "cancelled", "canceled":
            return .gray

        default:
            return .gray
        }
    }

    var jobStatusTitle: String {
        switch lowercased() {
        case "active":
            return "Aktif"

        case "completed", "done":
            return "Tamamlandı"

        case "cancelled", "canceled":
            return "İptal Edildi"

        default:
            return self
        }
    }
}
