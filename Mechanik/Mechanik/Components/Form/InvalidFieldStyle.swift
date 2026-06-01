import SwiftUI

enum InvalidFieldStyle {
    static let borderColor = Color.red.opacity(0.75)
    static let borderWidth: CGFloat = 1.5
    static let backgroundColor = Color.red.opacity(0.06)
    static let labelColor = Color.red.opacity(0.85)
}

struct InvalidFieldBorder: ViewModifier {
    let isInvalid: Bool
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(isInvalid ? InvalidFieldStyle.backgroundColor : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isInvalid ? InvalidFieldStyle.borderColor : Color.clear,
                        lineWidth: isInvalid ? InvalidFieldStyle.borderWidth : 0
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: isInvalid)
    }
}

extension View {
    func invalidFieldBorder(isInvalid: Bool, cornerRadius: CGFloat = 16) -> some View {
        modifier(InvalidFieldBorder(isInvalid: isInvalid, cornerRadius: cornerRadius))
    }
}

struct ShakeEffect: GeometryEffect {
    var travel: CGFloat = 8
    var shakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = travel * sin(animatableData * .pi * shakes)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(trigger)))
    }
}

enum FormFieldAnchor: String {
    case plate
    case brand
    case model
    case year
    case engineSize
    case chassisNo
    case ownerName
    case ownerPhone
    case notes

    case jobTitle
    case jobMileage
    case jobLaborFee
    case jobNotes
    case jobQuickJobs

    case authName
    case authEmail
    case authPassword
    case authConfirmPassword

    case businessName
}
