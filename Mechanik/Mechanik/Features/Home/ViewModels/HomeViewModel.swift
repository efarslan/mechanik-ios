import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var businessName = "Panel"
    @Published private(set) var access: BusinessAccess?
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var jobs: [JobListItem] = []

    private let businessService: BusinessService
    private let vehicleService: VehicleService
    private var lastUser: User?


    init() {
        self.businessService = BusinessService()
        self.vehicleService = .shared
    }

    init(
        businessService: BusinessService,
        vehicleService: VehicleService
    ) {
        self.businessService = businessService
        self.vehicleService = vehicleService
    }

    var recentJobs: [JobListItem] {
        Array(dashboardJobs.prefix(3))
    }
    
    var dashboardJobs: [JobListItem] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? .distantPast

        let activeJobs = nonCancelledJobs
            .filter { $0.status == .active }

        let recentCompleted = nonCancelledJobs
            .filter {
                $0.status == .completed &&
                ($0.updatedAt ?? $0.createdAt ?? .distantPast) >= weekAgo
            }

        return (activeJobs + recentCompleted)
            .sorted {
                ($0.updatedAt ?? $0.createdAt ?? .distantPast) >
                ($1.updatedAt ?? $1.createdAt ?? .distantPast)
            }
    }
    
    var kpis: DashboardKPIs {
        let active = nonCancelledJobs.filter { $0.status == .active }
        let completed = nonCancelledJobs.filter { $0.status == .completed }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? .distantPast

        return DashboardKPIs(
            activeCount: active.count,
            completedThisWeek: completed.filter { ($0.createdAt ?? .distantPast) >= weekAgo }.count,
            activeValue: active.reduce(0) { $0 + $1.totalAmount },
            staleCount: active.filter(isStale(_:)).count
        )
    }

    var alerts: [AlertItem] {
        let activeJobs = nonCancelledJobs.filter { $0.status == .active }

        let stale = activeJobs
            .filter(isStale(_:))
            .prefix(3)
            .map { job in
                AlertItem(
                    id: "stale-\(job.id)",
                    kind: .stale,
                    job: job,
                    vehicle: vehicle(for: job),
                    subtitle: "İşlem \(daysOpen(for: job)) gündür açık."
                )
            }

        let missingPhone = activeJobs
            .filter { vehicle(for: $0)?.ownerPhone?.isEmpty != false }
            .prefix(2)
            .map { job in
                AlertItem(
                    id: "phone-\(job.id)",
                    kind: .missingPhone,
                    job: job,
                    vehicle: vehicle(for: job),
                    subtitle: "Araç sahibinin telefon numarası eksik."
                )
            }

        let zeroLabor = activeJobs
            .filter { ($0.laborFee ?? 0) <= 0 }
            .prefix(2)
            .map { job in
                AlertItem(
                    id: "labor-\(job.id)",
                    kind: .zeroLabor,
                    job: job,
                    vehicle: vehicle(for: job),
                    subtitle: "İşçilik ücreti 0 ₺ olarak belirtilmiş."
                )
            }

        return stale + missingPhone + zeroLabor
    }

    var trendPoints: [TrendPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -13, to: endDate) ?? endDate

        return (0..<14).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date

            let dailyJobs = nonCancelledJobs.filter {
                guard let createdAt = $0.createdAt else { return false }
                return createdAt >= date && createdAt < nextDay
            }

            return TrendPoint(
                date: date,
                jobs: dailyJobs.count,
                labor: dailyJobs.reduce(0) { $0 + ($1.laborFee ?? 0) },
                parts: dailyJobs.reduce(0) { $0 + (($1.totalAmount) - ($1.laborFee ?? 0)) }
            )
        }
    }

    var totalFourteenDayJobs: Int {
        trendPoints.reduce(0) { $0 + $1.jobs }
    }
    
    var totalFourteenDayLabor: Double {
        trendPoints.reduce(0) { $0 + $1.labor }
    }
    
    var totalFourteenDayParts: Double {
        trendPoints.reduce(0) { $0 + $1.parts }
    }
    
    var totalFourteenDayRevenue: Double {
        trendPoints.reduce(0) { $0 + ($1.labor + $1.parts) }
    }

    var canCreateVehicle: Bool {
        access?.canCreateVehicle == true
    }

    var shouldShowVerificationBanner: Bool {
        lastUser?.emailVerified == false
    }

    func load(user: User?) async {
        guard let user else {
            errorMessage = "Giriş bilgisi bulunamadı."
            return
        }

        lastUser = user
        await fetchDashboard(for: user)
    }

    func reload() async {
        guard let user = lastUser else { return }
        await fetchDashboard(for: user)
    }

    func vehicle(for job: JobListItem) -> Vehicle? {
        vehicles.first(where: { $0.id == job.vehicleId })
    }

    func handleJobUpdated(_ updatedJob: JobListItem) {
        if let index = jobs.firstIndex(where: { $0.id == updatedJob.id }) {
            jobs[index] = updatedJob
        }
    }

    private var nonCancelledJobs: [JobListItem] {
        jobs.filter { $0.status != .cancelled }
    }

    private func fetchDashboard(for user: User) async {
        isLoading = true
        errorMessage = nil

        do {
            guard let access = try await businessService.fetchBusinessAccess(userId: user.id, email: user.email) else {
                self.access = nil
                self.vehicles = []
                self.jobs = []
                self.businessName = "Panel"
                self.errorMessage = "İşletme bulunamadı."
                self.isLoading = false
                return
            }

            async let businessNameTask = businessService.fetchBusinessName(businessId: access.businessId)
            async let vehiclesTask = vehicleService.fetchVehicles(businessId: access.businessId)
            async let jobsTask = vehicleService.fetchJobs(businessId: access.businessId, includeCancelled: true)

            self.access = access
            self.businessName = try await businessNameTask ?? "Panel"
            self.vehicles = try await vehiclesTask
            self.jobs = try await jobsTask
        } catch {
            self.errorMessage = "Ana ekran verileri yüklenemedi."
        }

        isLoading = false
    }

    private func isStale(_ job: JobListItem) -> Bool {
        guard let createdAt = job.createdAt else { return false }
        let threshold = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? .distantPast
        return createdAt <= threshold
    }

    private func daysOpen(for job: JobListItem) -> Int {
        guard let createdAt = job.createdAt else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0)
    }
}
