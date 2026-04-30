//
//  AppState.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//

import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {

    enum Route {
        case login
        case mainTabs
    }

    @Published private(set) var route: Route = .login
    @Published private(set) var isAuthResolved: Bool = false
    @Published private(set) var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var currentBusinessId: String?
    @Published var selectedTab: Int = 0

    private let authService: FirebaseAuthService
    private var authStateListenerHandle: NSObjectProtocol?

    init(authService: FirebaseAuthService? = nil) {
        self.authService = authService ?? .shared
        syncCurrentSession()
        startAuthListener()
    }

    func login(user: User, selectedTab: Int = 0) {
        currentUser = user
        isLoggedIn = true
        route = .mainTabs
        isAuthResolved = true
        currentBusinessId = nil
        self.selectedTab = selectedTab
    }

    func logout() {
        do {
            try authService.logout()
        } catch {
            applySignedOutState()
        }
    }

    private func syncCurrentSession() {
        if let user = authService.getCurrentUser() {
            login(user: user)
        } else {
            applySignedOutState()
        }
    }

    private func startAuthListener() {
        authStateListenerHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                guard let self else { return }

                if let user {
                    self.login(user: user, selectedTab: self.selectedTab)
                } else {
                    self.applySignedOutState()
                }
            }
        }
    }

    private func applySignedOutState() {
        currentUser = nil
        isLoggedIn = false
        route = .login
        isAuthResolved = true
        currentBusinessId = nil
        selectedTab = 0
    }
}
