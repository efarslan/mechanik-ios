import SwiftUI

struct BusinessSetupGateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var businessName = ""
    @State private var isCreating = false
    @State private var businessNameError: String?
    @State private var errorMessage: String?

    private let service = SettingsService()

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            CreateBusinessView(
                businessName: $businessName,
                businessNameError: businessNameError,
                isCreating: isCreating,
                onCreate: {
                    Task { await createBusiness() }
                },
                onLogout: {
                    appState.logout()
                }
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

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
}

#Preview {
    BusinessSetupGateView()
        .environmentObject(AppState())
}
