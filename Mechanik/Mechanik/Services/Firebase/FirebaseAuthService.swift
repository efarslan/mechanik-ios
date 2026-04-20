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
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        let firebaseUser = result.user
        
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? ""
        )
    }
    
    // MARK: - REGISTER
    func register(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let firebaseUser = result.user
        
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? ""
        )
    }
    
    // MARK: - LOGOUT
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - CURRENT USER
    func getCurrentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? ""
        )
    }
}