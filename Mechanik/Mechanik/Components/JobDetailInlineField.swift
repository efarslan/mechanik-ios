//
//  JobDetailInlineField.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobDetailInlineField<Content: View>: View {

    let label: String

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)

            content()
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemFill))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                )
        }
        .frame(maxWidth: .infinity)
    }
}
