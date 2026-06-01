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
        case resolvingSession
        case emailVerification
        case businessSetup
        case pendingApproval
        case mainTabs
    }

    @Published private(set) var route: Route = .resolvingSession
    @Published private(set) var isAuthResolved: Bool = false
    @Published private(set) var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published private(set) var currentBusinessId: String?
    @Published private(set) var pendingBusinessName: String?
    @Published var selectedTab: Int = 0

    private let authService: FirebaseAuthService
    private let businessService: BusinessService
    private var authStateListenerHandle: NSObjectProtocol?
    private var isResolvingAuthenticatedFlow = false

    init(
        authService: FirebaseAuthService? = nil,
        businessService: BusinessService? = nil
    ) {
        self.authService = authService ?? .shared
        self.businessService = businessService ?? BusinessService()
        syncCurrentSession()
        startAuthListener()
    }

    func login(user: User, selectedTab: Int = 0) async {
        await applyAuthenticatedUser(user, selectedTab: selectedTab)
    }

    func logout() {
        do {
            try authService.logout()
        } catch {
            applySignedOutState()
        }
    }

    func refreshCurrentUser() async {
        guard isLoggedIn else { return }

        do {
            if let user = try await authService.reloadCurrentUser() {
                currentUser = user
                isLoggedIn = true
                isAuthResolved = true
                await resolveAuthenticatedFlow(for: user, selectedTab: selectedTab, showsLoading: false)
            } else {
                applySignedOutState()
            }
        } catch {
            if authService.getCurrentUser() == nil {
                applySignedOutState()
            } else if let currentUser {
                await resolveAuthenticatedFlow(for: currentUser, selectedTab: selectedTab, showsLoading: false)
            }
        }
    }

    func markBusinessSetupCompleted(businessId: String? = nil) async {
        if let businessId {
            currentBusinessId = businessId
        }

        if let currentUser {
            await resolveAuthenticatedFlow(for: currentUser, selectedTab: selectedTab, showsLoading: true)
        }
    }

    private func syncCurrentSession() {
        if let user = authService.getCurrentUser() {
            currentUser = user
            isLoggedIn = true
            route = .resolvingSession
            isAuthResolved = true

            Task {
                await applyAuthenticatedUser(user, selectedTab: selectedTab)
            }
        } else {
            applySignedOutState()
        }
    }

    private func startAuthListener() {
        authStateListenerHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                guard let self else { return }

                if let user {
                    if self.isLoggedIn, self.currentUser?.id == user.id {
                        self.currentUser = user
                        await self.resolveAuthenticatedFlow(for: user, selectedTab: self.selectedTab, showsLoading: false)
                    } else {
                        await self.applyAuthenticatedUser(user, selectedTab: self.selectedTab)
                    }
                } else {
                    self.applySignedOutState()
                }
            }
        }
    }

    private func applyAuthenticatedUser(_ user: User, selectedTab: Int) async {
        currentUser = user
        isLoggedIn = true
        isAuthResolved = true
        self.selectedTab = selectedTab
        await resolveAuthenticatedFlow(for: user, selectedTab: selectedTab, showsLoading: true)
    }

    private func resolveAuthenticatedFlow(for user: User, selectedTab: Int, showsLoading: Bool) async {
        guard !isResolvingAuthenticatedFlow else { return }
        isResolvingAuthenticatedFlow = true
        defer { isResolvingAuthenticatedFlow = false }

        if showsLoading {
            route = .resolvingSession
        }

        guard user.emailVerified else {
            currentBusinessId = nil
            pendingBusinessName = nil
            route = .emailVerification
            return
        }

        do {
            switch try await businessService.resolveMembership(
                userId: user.id,
                email: user.email,
                name: user.name
            ) {
            case .active(let businessId):
                currentBusinessId = businessId
                pendingBusinessName = nil
                route = .mainTabs
                self.selectedTab = selectedTab
            case .pending(_, let businessName):
                currentBusinessId = nil
                pendingBusinessName = businessName
                route = .pendingApproval
            case .none:
                currentBusinessId = nil
                pendingBusinessName = nil
                route = .businessSetup
            }
        } catch {
            currentBusinessId = nil
            pendingBusinessName = nil
            route = .businessSetup
        }
    }

    private func applySignedOutState() {
        currentUser = nil
        isLoggedIn = false
        route = .login
        isAuthResolved = true
        currentBusinessId = nil
        pendingBusinessName = nil
        selectedTab = 0
    }
}
