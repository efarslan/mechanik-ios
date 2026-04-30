//
//  FirebaseAuthService.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import Foundation
import FirebaseAuth

final class FirebaseAuthService {
    
    // MARK: - Shared (opsiyonel ama önerilir)
    static let shared = FirebaseAuthService()
    private init() {}
    
    // MARK: - LOGIN
    func login(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: normalizedEmail(email), password: password)
        return mapUser(result.user)
    }
    
    // MARK: - REGISTER
    func register(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: normalizedEmail(email), password: password)
        return mapUser(result.user)
    }

    func sendEmailVerification() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        try await currentUser.sendEmailVerification()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: normalizedEmail(email))
    }

    func fetchSignInMethods(email: String) async throws -> [String] {
        try await Auth.auth().fetchSignInMethods(forEmail: normalizedEmail(email))
    }
    
    // MARK: - LOGOUT
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - CURRENT USER
    func getCurrentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return mapUser(firebaseUser)
    }

    func addAuthStateListener(_ listener: @escaping (User?) -> Void) -> NSObjectProtocol {
        Auth.auth().addStateDidChangeListener { _, firebaseUser in
            listener(firebaseUser.map(self.mapUser))
        }
    }

    func removeAuthStateListener(_ handle: NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    private func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func mapUser(_ firebaseUser: FirebaseAuth.User) -> User {
        User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            emailVerified: firebaseUser.isEmailVerified
        )
    }
}
