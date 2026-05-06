//
//  trendsSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct TrendsSectionView: View {
    let trendPoints: [TrendPoint]
    let chartMode: ChartMode
    let onChartModeChange: (ChartMode) -> Void

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {

                HStack(alignment: .top) {
                    Text("Son 14 Gün")
                        .font(.headline)

                    Spacer()
                }

                Picker("Grafik", selection: Binding(
                    get: { chartMode },
                    set: { onChartModeChange($0) }
                )) {
                    ForEach(ChartMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                HomeChartView(
                    trendPoints: trendPoints,
                    chartMode: chartMode
                )
                .frame(height: 190)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {

                        CompactInsightPill(
                            title: "14 Günlük İş",
                            value: "\(trendPoints.reduce(0) { $0 + $1.jobs })",
                            tint: .green
                        )

                        CompactInsightPill(
                            title: "14 Günlük Ciro",
                            value: trendPoints
                                .reduce(0) { $0 + ($1.labor + $1.parts) }
                                .formattedCurrency,
                            tint: Color(red: 0.94, green: 0.75, blue: 0.20)
                        )

                        CompactInsightPill(
                            title: "İşçilik / Parça",
                            value:
                                "\(trendPoints.reduce(0) { $0 + $1.labor }.formattedCurrency) / \(trendPoints.reduce(0) { $0 + $1.parts }.formattedCurrency)",
                            tint: .blue
                        )
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
}
