import SwiftUI

struct EmailVerificationGateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isRefreshing = false
    @State private var isSending = false
    @State private var message: String?
    @State private var errorMessage: String?

    private let authService = FirebaseAuthService.shared

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 88, height: 88)
                .background(Color.orange.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 10) {
                Text("E-postanızı doğrulayın")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Dashboard, araç ve işlem ekranlarına erişmek için e-posta doğrulaması zorunludur.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let email = appState.currentUser?.email, !email.isEmpty {
                Text(email)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Capsule())
            }

            VStack(spacing: 12) {
                Button {
                    Task { await refreshVerificationStatus() }
                } label: {
                    HStack(spacing: 8) {
                        if isRefreshing {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(isRefreshing ? "Kontrol Ediliyor..." : "Doğrulamayı Kontrol Et")
                            .font(.subheadline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color.black.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(isRefreshing)

                Button {
                    Task { await resendVerificationEmail() }
                } label: {
                    Text(isSending ? "Gönderiliyor..." : "Doğrulama E-postasını Tekrar Gönder")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(isSending)
            }

            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .multilineTextAlignment(.center)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("Çıkış Yap", role: .destructive) {
                appState.logout()
            }
            .font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
    }

    private func refreshVerificationStatus() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        message = nil
        errorMessage = nil

        await appState.refreshCurrentUser()

        if appState.currentUser?.emailVerified == false {
            message = "E-posta doğrulandıktan sonra bu ekrandan devam edebilirsiniz."
        }

        isRefreshing = false
    }

    private func resendVerificationEmail() async {
        guard !isSending else { return }
        isSending = true
        message = nil
        errorMessage = nil

        do {
            try await authService.sendEmailVerification()
            message = "Doğrulama e-postası tekrar gönderildi."
        } catch {
            errorMessage = "Doğrulama e-postası gönderilemedi."
        }

        isSending = false
    }
}

#Preview {
    EmailVerificationGateView()
        .environmentObject(AppState())
}
