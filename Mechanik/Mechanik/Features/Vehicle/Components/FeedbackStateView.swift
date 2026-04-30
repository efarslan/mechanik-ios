//
//  FeedbackStateView.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct FeedbackStateView: View {

    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {

            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
