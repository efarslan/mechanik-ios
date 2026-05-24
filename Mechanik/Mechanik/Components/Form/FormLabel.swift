//
//  FormLabel.swift
//  Mechanik
//
//  Created by efe arslan on 18.05.2026.
//


import SwiftUI

struct FormLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}