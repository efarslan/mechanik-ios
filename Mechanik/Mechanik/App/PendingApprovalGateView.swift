import SwiftUI

struct PendingApprovalGateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isRefreshing = false
    @State private var isCancelling = false
    @State private var showCancelConfirm = false
    @State private var errorMessage: String?

    private let service = SettingsService()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 88, height: 88)
                .background(Color.orange.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 10) {
                Text("Onay Bekleniyor")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                if let businessName = appState.pendingBusinessName, !businessName.isEmpty {
                    Text(businessName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(
                    "İşletme yöneticisi başvurunuzu henüz onaylamamış olabilir. Onaylandıktan sonra uygulamaya erişebilirsiniz."
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }

            if showCancelConfirm {
                cancelConfirmSection
            } else {
                VStack(spacing: 12) {
                    Button {
                        Task { await refreshStatus() }
                    } label: {
                        HStack(spacing: 8) {
                            if isRefreshing {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isRefreshing ? "Kontrol Ediliyor..." : "Onay Durumunu Kontrol Et")
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
                        showCancelConfirm = true
                    } label: {
                        Text("Başvuruyu İptal Et")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            if !showCancelConfirm {
                Button("Çıkış Yap", role: .destructive) {
                    appState.logout()
                }
                .font(.footnote.weight(.semibold))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
    }

    private var cancelConfirmSection: some View {
        VStack(spacing: 12) {
            Text("Başvurunuz silinecek ve işletme seçim ekranına döneceksiniz. Tekrar katılmak için yeni bir davet kodu gerekir.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Geri Dön") {
                    showCancelConfirm = false
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button(isCancelling ? "İptal ediliyor..." : "Evet, İptal Et") {
                    Task { await cancelRequest() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .frame(maxWidth: .infinity)
                .disabled(isCancelling)
            }
        }
    }

    private func refreshStatus() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        errorMessage = nil
        await appState.refreshCurrentUser()
        if appState.route == .pendingApproval {
            errorMessage = "Henüz onaylanmadı. Yönetici onayladığında otomatik erişim açılır."
        }
        isRefreshing = false
    }

    private func cancelRequest() async {
        guard let userId = appState.currentUser?.id, !isCancelling else { return }
        isCancelling = true
        errorMessage = nil

        do {
            try await service.cancelPendingMembership(userId: userId)
            showCancelConfirm = false
            await appState.markBusinessSetupCompleted()
        } catch {
            errorMessage = "Başvuru iptal edilemedi. Lütfen tekrar deneyin."
        }

        isCancelling = false
    }
}

#Preview {
    PendingApprovalGateView()
        .environmentObject(AppState())
}
