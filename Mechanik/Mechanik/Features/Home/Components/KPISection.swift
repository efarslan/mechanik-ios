//
//  kpiSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct KPISectionView: View {
    let kpis: DashboardKPIs
    let onVehiclesTap: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {

                DashboardMetricCard(
                    title: "Aktif İşler",
                    value: "\(kpis.activeCount)",
                    subtitle: "Şu an serviste",
                    tint: .green,
                    systemImage: "wrench.and.screwdriver.fill"
                )

                DashboardMetricCard(
                    title: "Bu Hafta",
                    value: "\(kpis.completedThisWeek)",
                    subtitle: "Tamamlanan iş",
                    tint: .blue,
                    systemImage: "checkmark.seal.fill"
                )

                DashboardMetricCard(
                    title: "Aktif Tutar",
                    value: kpis.activeValue.formattedCurrency,
                    subtitle: "İşçilik + parça",
                    tint: Color(red: 0.94, green: 0.75, blue: 0.20),
                    systemImage: "turkishlirasign.circle.fill",
                    compactValue: true
                )

                DashboardMetricCard(
                    title: "Geciken",
                    value: "\(kpis.staleCount)",
                    subtitle: "7+ gündür açık",
                    tint: kpis.staleCount > 0 ? .red : .gray,
                    systemImage: "clock.badge.exclamationmark.fill"
                )
            }
            .padding(.horizontal, 2)
        }
    }
}
