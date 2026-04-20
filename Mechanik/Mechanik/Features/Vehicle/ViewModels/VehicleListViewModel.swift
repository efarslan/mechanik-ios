//
//  VehicleListViewModel.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//

import Foundation
import Combine

@MainActor
final class VehicleListViewModel: ObservableObject {
    
    // MARK: - STATE
    @Published var vehicles: [Vehicle] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - DEPENDENCY
    private let service: VehicleService
    private let businessService = BusinessService()
    
    init(service: VehicleService = .shared) {
        self.service = service
    }
    
    // MARK: - FETCH
    @MainActor
    func fetchVehicles(userId: String, email: String?) {
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let businessId = try await businessService.fetchCurrentBusinessId(userId: userId, email: email) else {
                    self.errorMessage = "Business not found"
                    self.isLoading = false
                    return
                }
                self.vehicles = try await service.fetchVehicles(businessId: businessId)
                
                self.isLoading = false
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - DELETE
    func deleteVehicle(id: String, businessId: String) {
        Task {
            do {
                try await service.deleteVehicle(id: id)
                
                // local state update (optimistic UI)
                self.vehicles.removeAll { $0.id == id }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - CREATE (opsiyonel ama hazır dursun)
    func createVehicle(_ vehicle: Vehicle, businessId: String) {
        isLoading = true
        
        Task {
            do {
                _ = try await service.createVehicle(vehicle)
                self.isLoading = false
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
