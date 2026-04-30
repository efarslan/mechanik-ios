//
//  JobStatus.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

enum JobStatus: String, Codable {
    case active
    case completed
    case cancelled

    var color: Color {
        switch self {
        case .active:
            return .green
        case .completed:
            return Color(red: 0.94, green: 0.75, blue: 0.20)
        case .cancelled:
            return .gray
        }
    }

    var title: String {
        switch self {
        case .active:
            return "Aktif"
        case .completed:
            return "Tamamlandı"
        case .cancelled:
            return "İptal Edildi"
        }
    }
}

