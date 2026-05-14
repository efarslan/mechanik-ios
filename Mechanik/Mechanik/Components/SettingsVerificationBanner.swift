//
//  VerificationBanner.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct VerificationBanner: View {

    let onSend: () -> Void

    var body: some View {

        HStack(spacing: 12) {

            Image(systemName: "envelope.badge")
                .foregroundStyle(.appYellow)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {

                Text("E-posta doğrulanmadı")
                    .font(.subheadline.weight(.bold))

                Text(
                    "Bazı yönetim işlemleri doğrulama tamamlanana kadar kısıtlıdır."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button("Gönder") {
                onSend()
            }
            .font(.caption.weight(.bold))
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding(14)
        .background(Color.orange.opacity(0.12))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}
