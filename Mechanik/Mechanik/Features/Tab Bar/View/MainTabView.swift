//
//  MainTabView.swift
//  Mechanik
//
//  Created by efe arslan on 25.04.2026.
//


import SwiftUI

// MARK: - MAIN TAB VIEW
struct MainTabView: View {
    
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            
            // MARK: - HOME
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Ana Sayfa")
                }
                .tag(0)
            
            // MARK: - VEHICLES
            VehicleListView()
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Araçlar")
                }
                .tag(1)
            
            // MARK: - SETTINGS
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ayarlar")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
