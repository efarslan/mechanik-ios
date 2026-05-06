//
//  TrendPoint.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import Foundation

struct TrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let jobs: Int
    let labor: Double
    let parts: Double
}
