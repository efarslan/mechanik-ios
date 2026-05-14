//
//  CopyableTruncatedTextRow.swift
//  Mechanik
//
//  Created by efe arslan on 12.05.2026.
//


import SwiftUI

struct CopyableTruncatedTextRow: View {

    let label: String
    let value: String
    var truncateAfter: Int = 14

    @State private var copied = false

    private var truncatedValue: String {
        guard value.count > truncateAfter else { return value }

        let prefix = value.prefix(truncateAfter)
        return "\(prefix)..."
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            HStack(spacing: 8) {

                Text(truncatedValue)
                    .font(.system(.footnote, design: .monospaced).weight(.semibold))
                    .lineLimit(1)

                Button {
                    UIPasteboard.general.string = value

                    withAnimation(.easeInOut(duration: 0.2)) {
                        copied = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            copied = false
                        }
                    }

                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(copied ? .green : .secondary)
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CopyableTruncatedTextRow(
            label: "Kullanıcı ID",
            value: "1234567890abcdefghijklmnopqrstuvwxyz"
        )

        CopyableTruncatedTextRow(
            label: "İşletme ID",
            value: "mechanik-business-123456789"
        )
    }
    .padding()
}