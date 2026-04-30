//
//  VehicleFuelType.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//


enum VehicleFuelType: String, CaseIterable, Identifiable, Codable {
    case gasoline
    case diesel
    case electric
    case hybrid
    case lpg = "LPG"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gasoline:
            return "Benzin"
        case .diesel:
            return "Dizel"
        case .electric:
            return "Elektrik"
        case .hybrid:
            return "Hibrit"
        case .lpg:
            return "LPG"
        }
    }

    init(storageValue: String) {
        let normalizedValue = storageValue.lowercased()

        switch normalizedValue {
        case "gasoline":
            self = .gasoline
        case "diesel":
            self = .diesel
        case "electric":
            self = .electric
        case "hybrid":
            self = .hybrid
        case "lpg":
            self = .lpg
        default:
            self = .gasoline
        }
    }
}