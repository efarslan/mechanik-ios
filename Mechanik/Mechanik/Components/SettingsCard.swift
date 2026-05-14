//
//  SettingsCard.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct SettingsCard<Content: View>: View {

    let title: String
    let icon: String

    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 8) {

                ZStack {
                    Circle()
                        .fill(.appYellow)
                        .frame(width: 26, height: 26)

                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .bold))
                }

                Text(title)
                    .font(.headline)
            }

            content
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    SettingsCard(
        title: "Hesap",
        icon: "person.crop.circle.fill"
    ) {
        Text("deneme")
    }
}
