//
//  AppRouter.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import SwiftUI

struct AppRouter: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if !appState.isAuthResolved {
                ProgressView("Yükleniyor...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if appState.route == .mainTabs {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
