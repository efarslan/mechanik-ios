import SwiftUI

struct JobDetailImagePreviewSheet: View {
    let image: JobDetailPreviewImage

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let url = image.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let loadedImage):
                        loadedImage
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                    default:
                        ProgressView()
                            .tint(.white)
                    }
                }
            } else if let uiImage = image.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(16)
            }
        }
    }
}

struct JobDetailPreviewImage: Identifiable {
    let id = UUID()
    let url: URL?
    let image: UIImage?

    init(url: URL) {
        self.url = url
        self.image = nil
    }

    init(image: UIImage) {
        self.url = nil
        self.image = image
    }
}
