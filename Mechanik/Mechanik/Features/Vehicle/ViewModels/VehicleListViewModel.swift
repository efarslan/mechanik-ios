import Combine
import Foundation

@MainActor
final class VehicleListViewModel: ObservableObject {

    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var brandLogos: [String: String] = [:]
    @Published var searchText: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let service: VehicleService
    private let businessService: BusinessService
    private(set) var businessId: String?

    init(
        service: VehicleService? = nil,
        businessService: BusinessService? = nil
    ) {
        self.service = service ?? .shared
        self.businessService = businessService ?? BusinessService()
    }

    var filteredVehicles: [Vehicle] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return vehicles
        }

        let normalizedQuery = trimmedQuery.lowercased()
        return vehicles.filter { vehicle in
            vehicle.plate.lowercased().contains(normalizedQuery)
                || vehicle.brand.lowercased().contains(normalizedQuery)
                || vehicle.model.lowercased().contains(normalizedQuery)
                || vehicle.ownerName.lowercased().contains(normalizedQuery)
        }
    }

    func load(userId: String, email: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            async let businessIdTask = businessService.fetchCurrentBusinessId(userId: userId, email: email)
            async let brandsTask = service.fetchBrands()

            guard let resolvedBusinessId = try await businessIdTask else {
                vehicles = []
                businessId = nil
                errorMessage = "İşletme bulunamadı."
                isLoading = false
                return
            }

            let fetchedVehicles = try await service.fetchVehicles(businessId: resolvedBusinessId)
            let fetchedBrands = try await brandsTask

            businessId = resolvedBusinessId
            vehicles = fetchedVehicles
            brandLogos = Dictionary(uniqueKeysWithValues: fetchedBrands.compactMap { brand in
                guard let logoURL = brand.logoURL, !brand.name.isEmpty else { return nil }
                return (brand.name, logoURL)
            })
        } catch {
            errorMessage = "Araçlar yüklenirken bir hata oluştu."
        }

        isLoading = false
    }
}
