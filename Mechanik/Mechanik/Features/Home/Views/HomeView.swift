import Charts
import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedJob: JobListItem?
    @State private var chartMode: ChartMode = .jobs
    @State private var isNavigatingToNewVehicle = false
    @State private var shouldReloadAfterVehicleCreation = false
    @State private var showAllRecentJobs = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.recentJobs.isEmpty && viewModel.alerts.isEmpty {
                    HomeSkeletonView()
                } else {
                    content
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await appState.refreshCurrentUser()
                await viewModel.load(user: appState.currentUser)
            }
            .task {
                await viewModel.load(user: appState.currentUser)
            }
            .onChange(of: appState.currentUser?.emailVerified) { _, _ in
                Task {
                    await viewModel.load(user: appState.currentUser)
                }
            }
            .navigationDestination(isPresented: $isNavigatingToNewVehicle) {
                NewVehicleView(didCreateVehicle: {
                    shouldReloadAfterVehicleCreation = true
                })
                .environmentObject(appState)
            }
            .onChange(of: isNavigatingToNewVehicle) { _, isActive in
                guard !isActive, shouldReloadAfterVehicleCreation else { return }
                shouldReloadAfterVehicleCreation = false
                Task { await viewModel.reload() }
            }
            .sheet(item: $selectedJob) { job in
                NavigationStack {
                    JobDetailSheetView(
                        job: job,
                        businessId: viewModel.access?.businessId ?? "",
                        vehicleId: job.vehicleId,
                        onJobUpdated: viewModel.handleJobUpdated
                    )
                }
            }
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                Text("Mechanik")
                    .font(.custom("TimesNewRomanPS-BoldMT", size: 34, relativeTo: .largeTitle))

                HeroCardView(
                    businessName: viewModel.businessName,
                    canCreateVehicle: viewModel.canCreateVehicle,
                    onVehiclesTap: {
                        appState.selectedTab = 1
                    },
                    onCreateVehicleTap: {
                        isNavigatingToNewVehicle = true
                    }
                )

                if viewModel.shouldShowVerificationBanner {
                    VerificationBanner {
                        Task {
                            await viewModel.resendVerificationEmail()
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorBannerView(message: errorMessage)
                }

                if !viewModel.alerts.isEmpty {
                    AlertsSectionView(
                        alerts: viewModel.alerts,
                        onSelectJob: { job in
                            selectedJob = job
                        }
                    )
                }

                RecentJobsSectionView(
                    recentJobs: viewModel.recentJobs,
                    dashboardJobs: viewModel.dashboardJobs,
                    allJobsCount: viewModel.jobs.count,
                    showAll: showAllRecentJobs,
                    onToggleShowAll: {
                        withAnimation(.spring(duration: 0.3)) {
                            showAllRecentJobs.toggle()
                        }
                    },
                    onSelectJob: { job in
                        selectedJob = job
                    },
                    onVehiclesTap: {
                        appState.selectedTab = 1
                    },
                    vehicleProvider: { job in
                        viewModel.vehicle(for: job)
                    }
                )

                KPISectionView(
                    kpis: viewModel.kpis,
                    onVehiclesTap: {
                        appState.selectedTab = 1
                    }
                )

                TrendsSectionView(
                    trendPoints: viewModel.trendPoints,
                    chartMode: chartMode,
                    onChartModeChange: { chartMode = $0 }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
