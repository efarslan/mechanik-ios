import SwiftUI

struct BusinessSetupGateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var businessName = ""
    @State private var inviteCode = ""
    @State private var isCreating = false
    @State private var isJoining = false
    @State private var businessNameError: String?
    @State private var inviteCodeError: String?
    @State private var errorMessage: String?

    private let service = SettingsService()

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            BusinessOnboardingView(
                businessName: $businessName,
                inviteCode: $inviteCode,
                businessNameError: businessNameError,
                inviteCodeError: inviteCodeError,
                generalError: errorMessage,
                isCreating: isCreating,
                isJoining: isJoining,
                showsLogout: true,
                onCreate: {
                    Task { await createBusiness() }
                },
                onJoin: {
                    Task { await joinBusiness() }
                },
                onLogout: {
                    appState.logout()
                }
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
    }

    private func createBusiness() async {
        guard let user = appState.currentUser else { return }
        let name = FieldValidator.filteredBusinessName(
            businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        businessName = name
        businessNameError = FieldValidator.businessNameError(name)
        guard businessNameError == nil, !isCreating else { return }

        isCreating = true
        errorMessage = nil

        do {
            try await service.createBusiness(name: name, user: user)
            await appState.markBusinessSetupCompleted()
        } catch {
            errorMessage = "İşletme oluşturulamadı. Lütfen tekrar deneyin."
        }

        isCreating = false
    }

    private func joinBusiness() async {
        guard let user = appState.currentUser else { return }
        inviteCodeError = FieldValidator.inviteCodeError(inviteCode)
        guard inviteCodeError == nil, !isJoining else { return }

        isJoining = true
        errorMessage = nil

        do {
            try await service.joinBusiness(inviteCode: inviteCode, user: user)
            await appState.markBusinessSetupCompleted()
        } catch let error as BusinessJoinError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Davet kodu ile katılım sırasında hata oluştu."
        }

        isJoining = false
    }
}

#Preview {
    BusinessSetupGateView()
        .environmentObject(AppState())
}
