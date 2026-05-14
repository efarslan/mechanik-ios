//
//  SettingsActionButton.swift
//  Mechanik
//
//  Created by efe arslan on 12.05.2026.
//

import SwiftUI

struct SettingsActionButton: View {

    let title: String

    var bgColor: Color = .gray.opacity(0.3)
    var txtColor: Color = .primary
    var borderColor: Color? = nil

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(txtColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(bgColor)
                )

                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(borderColor ?? .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {

        SettingsActionButton(
            title: "Şifre Sıfırlama",
            bgColor: .appYellow,
            txtColor: .black
        ) {
            
        }

        SettingsActionButton(title: "İşletme Adını Düzenle") {

        }
    }
    .padding()
}
