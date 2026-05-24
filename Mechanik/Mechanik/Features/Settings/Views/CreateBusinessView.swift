//
//  CreateBusinessView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct CreateBusinessView: View {

    @Binding var businessName: String

    let isCreating: Bool

    let onCreate: () -> Void
    let onLogout: () -> Void

    private static let businessNameLengthRange = 3...50
    private static let allowedBusinessNameCharacters = CharacterSet.letters
        .union(.decimalDigits)
        .union(CharacterSet(charactersIn: "."))

    private var isBusinessNameValid: Bool {
        Self.businessNameLengthRange.contains(businessName.count)
    }

    var body: some View {

        VStack(spacing: 12) {

            Image(systemName: "sparkles")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.orange)

            Text("İşletme Oluştur")
                .font(.title3.weight(.bold))

            Text("Devam etmek için hesabınıza bağlı bir işletme oluşturun.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            AppTextField(title: "İşletme Adı", placeholder: "İşletme Adı 3-50 Karakter Olmalıdır", text: $businessName)
            
            HStack {
                Spacer()

                Text("\(businessName.count)/50")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Button {
                onCreate()
            } label: {

                Text(
                    isCreating
                    ? "Oluşturuluyor..."
                    : "İşletmeyi Oluştur"
                )
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.black.opacity(0.85))
            .disabled(isCreating || !isBusinessNameValid)

            Button(
                "Çıkış Yap",
                role: .destructive
            ) {
                onLogout()
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .padding(.horizontal, 16)
        
        .onChange(of: businessName) { _, newValue in
            let filteredName = Self.filteredBusinessName(newValue)
            if filteredName != newValue {
                businessName = filteredName
            }
        }
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
