//
//  AppState.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//

import Combine
import Foundation
import FirebaseAuth

@MainActor
final class AppState: ObservableObject {
    
    // MARK: - AUTH STATE
    @Published var isLoggedIn: Bool = false
    
    // MARK: - CURRENT USER
    @Published var currentUser: User?
    @Published var currentBusinessId: String?
    
    // MARK: - LOGIN
    func login(user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        
        self.currentBusinessId = nil
    }
    
    // MARK: - LOGOUT
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        self.currentBusinessId = nil
    }
}
