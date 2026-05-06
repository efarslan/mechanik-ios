//
//  errorBannerView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.08))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}
