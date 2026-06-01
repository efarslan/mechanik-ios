import SwiftUI

extension View {
    func formScrollFocus(
        anchor: FormFieldAnchor?,
        proxy: ScrollViewProxy,
        animation: Animation = .easeInOut(duration: 0.35)
    ) -> some View {
        onChange(of: anchor) { _, field in
            guard let field else { return }
            withAnimation(animation) {
                proxy.scrollTo(field.rawValue, anchor: .center)
            }
        }
    }
}
