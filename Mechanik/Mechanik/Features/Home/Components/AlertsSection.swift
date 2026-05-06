//
//  alertsSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct AlertsSectionView: View {
    let alerts: [AlertItem]
    let onSelectJob: (JobListItem) -> Void

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {

                HStack {
                    Text("Öncelikli Uyarılar")
                        .font(.headline)

                    Spacer()

                    Text("\(alerts.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.10))
                        .clipShape(Capsule())
                }

                ForEach(alerts) { alert in
                    Button {
                        onSelectJob(alert.job)
                    } label: {
                        HStack(spacing: 12) {

                            ZStack {
                                Circle()
                                    .fill(alert.kind.color.opacity(0.12))
                                    .frame(width: 38, height: 38)

                                Image(systemName: alert.kind.iconName)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(alert.kind.color)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(alert.job.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                Text(alert.vehicle?.plate ?? "Araç bilgisi eksik")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)

                                Text(alert.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
