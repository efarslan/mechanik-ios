//
//  VehicleListView.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import SwiftUI

struct VehicleListView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = VehicleListViewModel()
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationView {
            Group {
                
                // LOADING
                if vm.isLoading {
                    ProgressView("Loading vehicles...")
                }
                
                // ERROR
                else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                // EMPTY STATE
                else if vm.vehicles.isEmpty {
                    VStack(spacing: 12) {
                        Text("No vehicles found")
                        Button("Retry") {
                            load()
                        }
                    }
                }
                
                // LIST
                else {
                    List(vm.vehicles) { vehicle in
                        VStack(alignment: .leading) {
                            Text(vehicle.plate)
                                .font(.headline)
                            
                            Text("\(vehicle.brand) \(vehicle.model)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Vehicles")
            .task {
                if !hasLoaded {
                    hasLoaded = true
                    load()
                }
            }
        }
    }
    
    private func load() {
        guard let user = appState.currentUser else { return }
        vm.fetchVehicles(userId: user.id, email: user.email)
    }
}
