//
//  verificationBannerView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct VerificationBannerView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "envelope.badge")
                .font(.title3)
                .foregroundStyle(Color(red: 0.94, green: 0.75, blue: 0.20))

            VStack(alignment: .leading, spacing: 4) {
                Text("E-posta doğrulanmadı")
                    .font(.subheadline.weight(.semibold))

                Text("Bazı yönetim işlemleri doğrulama tamamlanana kadar kısıtlı kalabilir.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(red: 1.0, green: 0.98, blue: 0.90))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }
}
