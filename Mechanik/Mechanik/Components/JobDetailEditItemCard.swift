//
//  JobDetailEditItemCard.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobDetailEditItemCard: View {

    @Binding var item: JobQuickItem

    let allQuickJobNames: [String]
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 12) {

            // Operation picker
            Menu {
                ForEach(allQuickJobNames, id: \.self) { name in
                    Button(name) {
                        item.name = name
                    }
                }
            } label: {
                HStack {
                    Text(item.name.isEmpty ? "İşlem seçin..." : item.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(item.name.isEmpty ? .tertiary : .primary)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(.tertiarySystemFill))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            }

            // Fields
            HStack(spacing: 8) {

                JobDetailInlineField(label: "Marka") {
                    TextField("Marka", text: $item.brand)
                }

                JobDetailInlineField(label: "Adet") {
                    TextField(
                        "1",
                        value: $item.quantity,
                        format: .number
                    )
                    .keyboardType(.numberPad)
                }

                JobDetailInlineField(label: "Birim ₺") {
                    TextField(
                        "0",
                        value: $item.unitPrice,
                        format: .number
                    )
                    .keyboardType(.numberPad)
                }
            }

            // Footer
            HStack {

                Text("Toplam")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(item.lineTotal.formattedCurrency)
                    .font(.caption.weight(.bold))

                Spacer()

                Button(action: onRemove) {
                    Label("Sil", systemImage: "trash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}
