import SwiftUI

struct SkeletonView: View {
    var width: CGFloat?
    var height: CGFloat
    var cornerRadius: CGFloat
    var opacity: Double

    init(
        width: CGFloat? = nil,
        height: CGFloat,
        cornerRadius: CGFloat = 8,
        opacity: Double = 1
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.opacity = opacity
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.gray.opacity(0.16 * opacity))
            .frame(width: width, height: height)
            .shimmerEffect()
    }
}

struct CircleSkeletonView: View {
    var size: CGFloat
    var opacity: Double = 1

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.16 * opacity))
            .frame(width: size, height: size)
            .shimmerEffect()
    }
}
