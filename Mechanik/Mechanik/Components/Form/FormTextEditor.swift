import SwiftUI

struct FormTextEditor: View {
    let title: String
    @Binding var text: String
    var error: String? = nil
    var minHeight: CGFloat = 90

    private var isInvalid: Bool { error != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel(title: title, isInvalid: isInvalid)

            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                .invalidFieldBorder(isInvalid: isInvalid)

            FormErrorText(message: error)
        }
    }
}
