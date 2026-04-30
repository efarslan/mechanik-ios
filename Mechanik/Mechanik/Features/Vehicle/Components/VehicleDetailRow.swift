//
//  VehicleDetailRow.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct VehicleDetailRow: View {

    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack(spacing: 10) {

            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.white.opacity(0.55))
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 1) {

                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.40))

                Text(value)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(valueColor)
            }
        }
    }
}
