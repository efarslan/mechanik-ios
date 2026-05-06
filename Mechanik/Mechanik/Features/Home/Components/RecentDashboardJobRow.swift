//
//  RecentDashboardJobRow.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct RecentDashboardJobRow: View {
    let job: JobListItem
    let vehicle: Vehicle?

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(job.status.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(job.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(job.status.title)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(job.status.color)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(job.status.color.opacity(0.10))
                        .clipShape(Capsule())
                }

                Text(
                    vehicle.map {
                        "\($0.plate) · \($0.ownerName)"
                    } ?? "Araç bilgisi bulunamadı"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

                HStack(spacing: 6) {
                    if let createdAt = job.createdAt {
                        Text(Self.relativeDateFormatter.localizedString(for: createdAt, relativeTo: .now))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    if job.totalAmount > 0 {
                        Text("·")
                            .foregroundStyle(.tertiary)

                        Text(job.totalAmount.formattedCurrency)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
