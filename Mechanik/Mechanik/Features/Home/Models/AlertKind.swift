//
//  AlertKind.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//


import SwiftUI

enum AlertKind {
    case stale
    case missingPhone
    case zeroLabor
    case warning
    case critical

    var color: Color {
        switch self {
        case .stale:
            return .orange
        case .missingPhone:
            return .yellow
        case .zeroLabor:
            return .red
        case .warning:
            return .yellow
        case .critical:
            return .red
        }
    }

    var iconName: String {
        switch self {
        case .stale:
            return "clock"
        case .missingPhone:
            return "phone.badge.plus"
        case .zeroLabor:
            return "wrench.and.screwdriver"
        case .warning:
            return "exclamationmark.triangle"
        case .critical:
            return "xmark.octagon"
        }
    }
}
