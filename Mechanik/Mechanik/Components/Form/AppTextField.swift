//
//  AppTextField.swift
//  Mechanik
//
//  Created by efe arslan on 18.05.2026.
//

import SwiftUI

struct AppTextField: View {

    let title: String
    let placeholder: String
    @Binding var text: String

    var keyboardType: UIKeyboardType = .default
    var error: String? = nil
    var isDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            FormLabel(title: title)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(isDisabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(error == nil ? Color.clear : Color.red.opacity(0.4), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            FormErrorText(message: error)
        }
    }
}
