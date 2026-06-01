import SwiftUI

struct AppPickerField: View {

    let title: String
    let isSelected: Bool
    var isInvalid: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(
                    isInvalid
                        ? InvalidFieldStyle.labelColor
                        : (isSelected ? Color.black.opacity(0.82) : .secondary)
                )

            Spacer()

            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(isInvalid ? InvalidFieldStyle.labelColor : .secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
        .invalidFieldBorder(isInvalid: isInvalid)
    }
}
