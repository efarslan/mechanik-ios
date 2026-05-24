//
//  FormErrorText.swift
//  Mechanik
//
//  Created by efe arslan on 18.05.2026.
//


import SwiftUI

struct FormErrorText: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }
}