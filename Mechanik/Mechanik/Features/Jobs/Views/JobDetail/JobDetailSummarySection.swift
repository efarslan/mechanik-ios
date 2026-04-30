import SwiftUI

struct JobDetailSummarySection: View {
    let job: JobListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionHeader("Genel Bilgi")

            VStack(spacing: 0) {
                detailRow(label: "Başlık", value: job.title)

                if let notes = job.notes, !notes.isEmpty {
                    Divider().padding(.leading, 16)
                    detailRow(label: "Notlar", value: notes)
                }

                if let mileage = job.mileage {
                    Divider().padding(.leading, 16)
                    detailRow(
                        label: "Kilometre",
                        value: "\(mileage.formatted(.number.locale(Locale(identifier: "tr_TR")))) km"
                    )
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.top, 32)
    }
}

private extension JobDetailSummarySection {
    func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
            .padding(.bottom, 6)
    }

    func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
