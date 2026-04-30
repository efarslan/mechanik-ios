import SwiftUI

struct JobDetailItemsSection: View {
    let items: [JobQuickItem]
    let currentLaborFee: Double
    let grandTotal: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionHeader("Parça / İş")

            VStack(spacing: 0) {
                ForEach(Array(items.indices), id: \.self) { index in
                    let item = items[index]

                    if index > 0 {
                        Divider().padding(.leading, 16)
                    }

                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))

                            if !item.brand.isEmpty {
                                Text(item.brand)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text("\(item.quantity) adet")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        Text(item.lineTotal.formattedCurrency)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }

                if currentLaborFee > 0 {
                    Divider().padding(.leading, 16)

                    HStack {
                        Label("İşçilik Ücreti", systemImage: "wrench.and.screwdriver")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(currentLaborFee.formattedCurrency)
                            .font(.subheadline.weight(.bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }

                VStack(spacing: 0) {
                    Divider()

                    HStack {
                        Text("Genel Toplam")
                            .font(.subheadline.weight(.bold))

                        Spacer()

                        Text(grandTotal.formattedCurrency)
                            .font(.headline.weight(.bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.tertiarySystemFill))
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private extension JobDetailItemsSection {
    func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
            .padding(.bottom, 6)
    }
}
