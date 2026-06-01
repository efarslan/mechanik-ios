//
//  recentJobsSection.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct RecentJobsSectionView: View {
    let recentJobs: [JobListItem]
    let dashboardJobs: [JobListItem]
    let allJobsCount: Int
    let showAll: Bool
    let onToggleShowAll: () -> Void
    let onSelectJob: (JobListItem) -> Void
    let onVehiclesTap: () -> Void
    let vehicleProvider: (JobListItem) -> Vehicle?

    private var jobsToShow: [JobListItem] {
        showAll ? dashboardJobs : recentJobs
    }

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {

                HStack {
                    Text("Son İşlemler")
                        .font(.headline)

                    Spacer()

                    Button("Araçlar") {
                        onVehiclesTap()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }

                if recentJobs.isEmpty {
                    emptyState
                } else {
                    jobsList

                    if allJobsCount > 5 {
                        toggleButton
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.tertiary)

            Text("Henüz iş kaydı yok")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var jobsList: some View {
        ForEach(jobsToShow) { job in
            Button {
                onSelectJob(job)
            } label: {
                RecentDashboardJobRow(
                    job: job,
                    vehicle: vehicleProvider(job)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var toggleButton: some View {
        Button {
            onToggleShowAll()
        } label: {
            HStack(spacing: 6) {
                Text(showAll ? "Daha Az Göster" : "Daha Fazla Göster")

                Image(systemName: showAll ? "chevron.up" : "chevron.down")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.top, 6)
        }
        .buttonStyle(.plain)
    }
}
