//
//  VehicleStatsItem.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct VehicleStatsItem: View {

    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(spacing: 4) {

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(valueColor)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}
