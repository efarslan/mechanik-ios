//
//  AppInputField.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct AppInputField: View {

    let title: String
    let placeholder: String

    @Binding var text: String

    var keyboardType: UIKeyboardType = .default

    let error: String?

    var isDisabled: Bool = false

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(
                    isDisabled
                    ? Color.secondary.opacity(0.5)
                    : .secondary
                )

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(isDisabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    isDisabled
                    ? Color(
                        red: 0.94,
                        green: 0.94,
                        blue: 0.93
                    )
                    : Color(
                        red: 0.97,
                        green: 0.97,
                        blue: 0.96
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                    .stroke(
                        error == nil
                        ? Color.clear
                        : Color.red.opacity(0.4),
                        lineWidth: 1
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
                .foregroundStyle(
                    isDisabled
                    ? .secondary
                    : .primary
                )

            if let error {

                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
