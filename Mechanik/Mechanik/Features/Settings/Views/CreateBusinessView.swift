//
//  CreateBusinessView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct CreateBusinessView: View {

    @Binding var businessName: String
    var businessNameError: String?
    let isCreating: Bool
    let onCreate: () -> Void
    let onLogout: () -> Void

    private var isBusinessNameValid: Bool {
        FieldValidator.businessNameError(businessName) == nil
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

            AppTextField(
                title: "İşletme Adı",
                placeholder: "İşletme adı 3-50 karakter",
                text: $businessName,
                error: businessNameError
            )
            .id(FormFieldAnchor.businessName.rawValue)
            
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
            let filteredName = FieldValidator.filteredBusinessName(newValue)
            if filteredName != newValue {
                businessName = filteredName
            }
        }
    }
}

#Preview {
    BusinessSetupGateView()
        .environmentObject(AppState())
}
