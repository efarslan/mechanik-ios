import SwiftUI

struct SkeletonModifier<Placeholder: View>: ViewModifier {
    let isLoading: Bool
    @ViewBuilder let placeholder: () -> Placeholder

    func body(content: Content) -> some View {
        if isLoading {
            placeholder()
                .transition(.opacity)
        } else {
            content
        }
    }
}

extension View {
    func skeleton<Placeholder: View>(
        isLoading: Bool,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, placeholder: placeholder))
    }
}
