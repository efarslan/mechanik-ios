//
//  DashboardMetricCard.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct DashboardMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    let systemImage: String
    var compactValue: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .frame(width: 38, height: 38)

                Image(systemName: systemImage)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }

            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.7)
                .foregroundStyle(.secondary)

            Text(value)
                .font(
                    compactValue
                    ? .title3.weight(.bold)
                    : .system(size: 28, weight: .bold, design: .rounded)
                )
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(
            width: 185,
            height: 170,
            alignment: .topLeading
        )
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}
