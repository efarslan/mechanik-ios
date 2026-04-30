//
//  JobDetailImagesSection.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobDetailImagesSection: View {

    @Binding var images: [String]
    let newImages: [PickedImage]

    let isEditMode: Bool
    let allImagesCount: Int
    let fileError: String?

    let onAddTapped: () -> Void
    let onRemoveRemote: (Int) -> Void
    let onRemoveLocal: (UUID) -> Void
    let onPreviewRemote: (URL) -> Void
    let onPreviewLocal: (UIImage) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 3
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            sectionHeader

            LazyVGrid(columns: columns, spacing: 8) {

                ForEach(Array(images.enumerated()), id: \.offset) { index, url in
                    if let remoteURL = URL(string: url) {
                        remoteImageCell(
                            url: remoteURL,
                            removeAction: isEditMode
                                ? { onRemoveRemote(index) }
                                : nil
                        )
                    }
                }

                ForEach(newImages) { image in
                    localImageCell(
                        image: image.image,
                        removeAction: isEditMode
                            ? { onRemoveLocal(image.id) }
                            : nil
                    )
                }

                if isEditMode && allImagesCount < 5 {
                    addButton
                }
            }

            if let fileError {
                Label(fileError, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 4)
            }
        }
    }
}
// MARK: - Helpers

private extension JobDetailImagesSection {

    var sectionHeader: some View {
        Text("GÖRSELLER")
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
            .padding(.bottom, 6)
    }

    var addButton: some View {
        Button(action: onAddTapped) {
            VStack(spacing: 6) {
                Image(systemName: "plus.circle")
                    .font(.title3.weight(.semibold))

                Text("Ekle")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    func remoteImageCell(
        url: URL,
        removeAction: (() -> Void)?
    ) -> some View {

        ZStack(alignment: .topTrailing) {

            AsyncImage(url: url) { phase in
                switch phase {

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                        )
                        .onTapGesture {
                            onPreviewRemote(url)
                        }

                default:
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 100)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.75)
                    )
                }
            }

            if let removeAction {
                removeButton(action: removeAction)
            }
        }
    }

    func localImageCell(
        image: UIImage,
        removeAction: (() -> Void)?
    ) -> some View {

        ZStack(alignment: .topTrailing) {

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                )
                .onTapGesture {
                    onPreviewLocal(image)
                }

            if let removeAction {
                removeButton(action: removeAction)
            }
        }
    }

    func removeButton(
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            Image(systemName: "xmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Material.ultraThinMaterial)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(6)
    }
}
