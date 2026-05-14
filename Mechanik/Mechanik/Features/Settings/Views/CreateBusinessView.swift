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

            TextField("İşletme adı", text: $businessName)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )

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
            .disabled(
                isCreating
                || businessName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )

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
    }
}
