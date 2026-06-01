import Combine
import Foundation
import FirebaseAuth

@MainActor
final class LoginViewModel: ObservableObject {

    struct FormErrors {
        var name: String?
        var email: String?
        var password: String?
        var confirmPassword: String?

        var hasErrors: Bool {
            name != nil || email != nil || password != nil || confirmPassword != nil
        }

        var firstInvalidAnchor: FormFieldAnchor? {
            if name != nil { return .authName }
            if email != nil { return .authEmail }
            if password != nil { return .authPassword }
            if confirmPassword != nil { return .authConfirmPassword }
            return nil
        }
    }

    enum AuthMode {
        case signIn
        case owner
    }

    @Published var mode: AuthMode = .signIn
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showPassword: Bool = false
    @Published var showConfirmPassword: Bool = false

    @Published var isSubmitting: Bool = false
    @Published var errors = FormErrors()
    @Published var focusFieldAnchor: FormFieldAnchor?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    @Published var isForgotPasswordPresented: Bool = false
    @Published var forgotEmail: String = ""
    @Published var isForgotPasswordLoading: Bool = false
    @Published var forgotPasswordErrorMessage: String?
    @Published var forgotPasswordSuccessMessage: String?

    private let authService: FirebaseAuthService

    init(authService: FirebaseAuthService? = nil) {
        self.authService = authService ?? .shared
    }

    func switchMode(to newMode: AuthMode) {
        guard newMode != mode else { return }

        mode = newMode
        errors = FormErrors()
        errorMessage = nil
        successMessage = nil
        name = ""
        password = ""
        confirmPassword = ""
        showPassword = false
        showConfirmPassword = false
    }

    func submit(appState: AppState) async {
        errors = FormErrors()
        errorMessage = nil
        successMessage = nil

        if let validationError = validateForm() {
            errorMessage = validationError
            return
        }

        isSubmitting = true
        let normalizedEmail = normalized(email)

        do {
            switch mode {
            case .signIn:
                let user = try await authService.login(email: normalizedEmail, password: password)
                await appState.login(user: user, selectedTab: 0)
            case .owner:
                let user = try await authService.register(email: normalizedEmail, password: password, name: normalizedName(name))
                try await authService.sendEmailVerification()
                successMessage = "Hesap oluşturuldu. Doğrulama e-postası gönderildi."
                await appState.login(user: user, selectedTab: 0)
            }
        } catch {
            await handleSubmitError(error, normalizedEmail: normalizedEmail)
        }

        isSubmitting = false
    }

    func openForgotPasswordSheet() {
        forgotEmail = normalized(email)
        forgotPasswordErrorMessage = nil
        forgotPasswordSuccessMessage = nil
        isForgotPasswordPresented = true
    }

    func resetPassword() async {
        forgotPasswordErrorMessage = nil
        forgotPasswordSuccessMessage = nil

        let normalizedEmail = normalized(forgotEmail)

        guard !normalizedEmail.isEmpty else {
            forgotPasswordErrorMessage = "E-posta adresi zorunludur."
            return
        }

        if let emailError = FieldValidator.emailError(normalizedEmail) {
            forgotPasswordErrorMessage = emailError
            return
        }

        isForgotPasswordLoading = true

        do {
            try await authService.sendPasswordReset(email: normalizedEmail)
            forgotPasswordSuccessMessage = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
        } catch {
            forgotPasswordErrorMessage = mapFirebaseError(error, mode: .signIn)
        }

        isForgotPasswordLoading = false
    }

    private func validateForm() -> String? {
        var nextErrors = FormErrors()
        let normalizedEmail = normalized(email)
        let isRegister = mode == .owner

        if isRegister {
            nextErrors.name = FieldValidator.nameError(name)
        }
        nextErrors.email = FieldValidator.emailError(normalizedEmail)
        nextErrors.password = FieldValidator.passwordError(password, isRegister: isRegister)
        if isRegister {
            nextErrors.confirmPassword = FieldValidator.confirmPasswordError(
                password: password,
                confirmPassword: confirmPassword
            )
        }

        errors = nextErrors
        focusFieldAnchor = nextErrors.firstInvalidAnchor
        guard nextErrors.hasErrors else { return nil }

        return nextErrors.name
            ?? nextErrors.email
            ?? nextErrors.password
            ?? nextErrors.confirmPassword
    }

    private func handleSubmitError(_ error: Error, normalizedEmail: String) async {
        let code = authErrorCode(from: error)

        if mode == .signIn,
           code == .userNotFound || code == .wrongPassword || code == .invalidCredential {
            do {
                let methods = try await authService.fetchSignInMethods(email: normalizedEmail)
                errorMessage = methods.isEmpty ? "Kullanıcı Bulunamadı." : "E-posta veya şifre hatalı."
            } catch {
                errorMessage = "E-posta veya şifre hatalı."
            }
            return
        }

        errorMessage = mapFirebaseError(error, mode: mode)
    }

    private func mapFirebaseError(_ error: Error, mode: AuthMode) -> String {
        switch authErrorCode(from: error) {
        case .invalidEmail?:
            return "Geçerli bir e-posta adresi girin."
        case .invalidCredential?, .wrongPassword?, .userNotFound?:
            return "E-posta veya şifre hatalı."
        case .tooManyRequests?:
            return "Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin."
        case .emailAlreadyInUse?:
            return "Bu e-posta ile zaten bir hesap var."
        case .weakPassword?:
            return "Daha güçlü bir şifre girin."
        case .networkError?:
            return "Ağ bağlantısı hatası."
        default:
            return mode == .signIn
                ? "Giriş işlemi başarısız oldu. Lütfen tekrar deneyin."
                : "Kayıt işlemi başarısız oldu. Lütfen tekrar deneyin."
        }
    }

    private func authErrorCode(from error: Error) -> AuthErrorCode? {
        AuthErrorCode(rawValue: (error as NSError).code)
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func normalizedName(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
