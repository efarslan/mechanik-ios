import Combine
import Foundation
import FirebaseAuth

@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - INPUTS
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - OUTPUTS
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - DEPENDENCY
    private let authService: FirebaseAuthService
    private let appState: AppState
    
    init(authService: FirebaseAuthService = .shared,
         appState: AppState) {
        self.authService = authService
        self.appState = appState
    }
    
    // MARK: - LOGIN FLOW
    func login() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                let user = try await authService.login(
                    email: email,
                    password: password
                )
                
                appState.login(user: user)
                
                print("Logged in user: \(user.id)")
                
            } catch {
                errorMessage = mapError(error)
            }
            
            isLoading = false
        }
    }
    
    // MARK: - ERROR HANDLING
    private func mapError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email"
        case AuthErrorCode.userNotFound.rawValue:
            return "User not found"
        default:
            return error.localizedDescription
        }
    }
}
