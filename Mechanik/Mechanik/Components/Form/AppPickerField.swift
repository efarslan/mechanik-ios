//
//  AppPickerField.swift
//  Mechanik
//
//  Created by efe arslan on 18.05.2026.
//

import SwiftUI

struct AppPickerField: View {

    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(isSelected ? Color.black.opacity(0.82) : .secondary)

            Spacer()

            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
