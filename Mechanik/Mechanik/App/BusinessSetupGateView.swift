import SwiftUI

struct BusinessSetupGateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var businessName = ""
    @State private var isCreating = false
    @State private var errorMessage: String?

    private static let businessNameLengthRange = 3...50
    private static let allowedBusinessNameCharacters = CharacterSet.letters
        .union(.decimalDigits)
        .union(CharacterSet(charactersIn: "."))

    private let service = SettingsService()

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            CreateBusinessView(
                businessName: $businessName,
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
        let name = Self.filteredBusinessName(businessName.trimmingCharacters(in: .whitespacesAndNewlines))
        businessName = name
        guard Self.businessNameLengthRange.contains(name.count), !isCreating else {
            errorMessage = "İşletme adı 3-50 karakter olmalı; sadece harf, rakam ve nokta içerebilir."
            return
        }

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

    private static func filteredBusinessName(_ name: String) -> String {
        let allowedScalars = name.unicodeScalars.filter {
            allowedBusinessNameCharacters.contains($0)
        }
        let filteredName = String(String.UnicodeScalarView(allowedScalars))
        guard filteredName.count > businessNameLengthRange.upperBound else { return filteredName }
        return String(filteredName.prefix(businessNameLengthRange.upperBound))
    }
}

#Preview {
    BusinessSetupGateView()
        .environmentObject(AppState())
}
