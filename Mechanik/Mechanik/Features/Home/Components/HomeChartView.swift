//
//  HomeChartView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI
import Charts

struct HomeChartView: View {
    let trendPoints: [TrendPoint]
    let chartMode: ChartMode

    var body: some View {
        Chart(trendPoints) { point in
            switch chartMode {
            case .jobs:
                BarMark(
                    x: .value("Gün", point.date, unit: .day),
                    y: .value("İş", point.jobs)
                )
                .foregroundStyle(Color.green.gradient)
                .cornerRadius(5)

            case .revenue:
                AreaMark(
                    x: .value("Gün", point.date, unit: .day),
                    y: .value("Ciro", point.labor + point.parts)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.24),
                            Color.orange.opacity(0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Gün", point.date, unit: .day),
                    y: .value("Ciro", point.labor + point.parts)
                )
                .foregroundStyle(Color.orange)
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 2.2,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 3)) { value in
                AxisValueLabel(
                    format: .dateTime.day().month(.abbreviated).locale(Locale(identifier: "tr_TR"))
                )
                .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(
                    stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3])
                )
                .foregroundStyle(Color.gray.opacity(0.18))

                AxisValueLabel {
                    if chartMode == .jobs, let jobCount = value.as(Int.self) {
                        Text("\(jobCount)")
                    } else if let revenue = value.as(Double.self) {
                        Text(revenue >= 1000 ? "\(Int(revenue / 1000))k" : "\(Int(revenue))")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(Color(red: 0.98, green: 0.98, blue: 0.97))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
        }
    }
}
