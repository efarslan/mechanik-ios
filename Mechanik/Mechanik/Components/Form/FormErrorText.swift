import SwiftUI

struct FormErrorText: View {
    let message: String?

    var body: some View {
        if let message {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}
