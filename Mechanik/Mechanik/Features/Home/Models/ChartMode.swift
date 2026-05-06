//
//  ChartMode.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//


import Foundation

enum ChartMode: String, CaseIterable, Identifiable {
    case jobs
    case revenue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .jobs:
            return "İş Adedi"
        case .revenue:
            return "Ciro"
        }
    }
}