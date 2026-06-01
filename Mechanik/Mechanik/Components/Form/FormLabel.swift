import SwiftUI

struct FormLabel: View {
    let title: String
    var isInvalid: Bool = false

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isInvalid ? InvalidFieldStyle.labelColor : .secondary)
    }
}
