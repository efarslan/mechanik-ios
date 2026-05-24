//
//  AppMessageCard.swift
//  Mechanik
//
//  Created by efe arslan on 18.05.2026.
//


import SwiftUI

struct AppMessageCard: View {

    let title: String
    let message: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)

            Text(message)
                .font(.footnote)
                .foregroundStyle(color.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}