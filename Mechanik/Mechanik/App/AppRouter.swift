//
//  AppRouter.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import SwiftUI

struct AppRouter: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if !appState.isAuthResolved {
                AppLaunchSkeleton()
            } else {
                switch appState.route {
                case .login:
                    LoginView()
                case .resolvingSession:
                    AppLaunchSkeleton()
                case .emailVerification:
                    EmailVerificationGateView()
                case .businessSetup:
                    BusinessSetupGateView()
                case .pendingApproval:
                    PendingApprovalGateView()
                case .mainTabs:
                    MainTabView()
                }
            }
        }
        .dismissKeyboardOnTap()
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await appState.refreshCurrentUser()
            }
        }
    }
}

#Preview {
    AppRouter()
        .environmentObject(AppState())
}

