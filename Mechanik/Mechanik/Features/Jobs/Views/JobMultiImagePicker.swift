import PhotosUI
import SwiftUI

struct JobMultiImagePicker: UIViewControllerRepresentable {
    let maxSelectionCount: Int
    let onPick: ([Data]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = maxSelectionCount
        config.filter = .images

        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
}

extension JobMultiImagePicker {
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: ([Data]) -> Void

        init(onPick: @escaping ([Data]) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }

            Task {
                var images: [Data] = []

                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self),
                       let image = try? await result.itemProvider.loadImage(),
                       let data = image.jpegData(compressionQuality: 0.85) {
                        images.append(data)
                    }
                }

                await MainActor.run {
                    onPick(images)
                }
            }
        }
    }
}

private extension NSItemProvider {
    func loadImage() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            loadObject(ofClass: UIImage.self) { image, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let image = image as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: NSError(domain: "ImagePicker", code: -1))
                }
            }
        }
    }
}
