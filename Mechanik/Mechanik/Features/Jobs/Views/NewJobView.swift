import PhotosUI
import SwiftUI
import UIKit

struct NewJobView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = NewJobViewModel()
    @State private var hasLoaded = false
    @State private var isPresentingImagePicker = false

    let vehicleId: String
    let didCreateJob: (() -> Void)?

    init(vehicleId: String, didCreateJob: (() -> Void)? = nil) {
        self.vehicleId = vehicleId
        self.didCreateJob = didCreateJob
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(screenBackground)
            } else {
                VStack(spacing: 0) {
                    // Scroll içerik
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            if let errorMessage = viewModel.errorMessage {
                                infoCard(
                                    icon: "exclamationmark.circle.fill",
                                    title: "Bir sorun var",
                                    message: errorMessage,
                                    color: .red
                                )
                            }

                            if let infoMessage = viewModel.infoMessage {
                                infoCard(
                                    icon: "info.circle.fill",
                                    title: "Bilgi",
                                    message: infoMessage,
                                    color: .orange
                                )
                            }

                            basicInfoSection
                            quickJobsSection
                            imagesSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    .background(screenBackground)

                    // Sticky footer
                    footerButtons
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            screenBackground
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -4)
                        )
                }
            }
        }
        .navigationTitle("Yeni İşlem")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Geri")
                    }
                }
            }
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await viewModel.load(user: appState.currentUser, vehicleId: vehicleId)
        }
        .sheet(isPresented: $isPresentingImagePicker) {
            MultiImagePicker(maxSelectionCount: max(0, 5 - viewModel.attachments.count)) { images in
                viewModel.appendImages(images)
            }
        }
    }

    private var screenBackground: some View {
        Color(red: 0.97, green: 0.97, blue: 0.96).ignoresSafeArea()
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        let isComplete = !viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty

        return formSection(title: "Temel Bilgiler", subtitle: "İşlem başlığı ve araç kilometresi", step: 1, isComplete: isComplete) {
            inputField(title: "İşlem Başlığı *", placeholder: "Periyodik bakım", text: $viewModel.title)

            HStack(spacing: 12) {
                inputField(
                    title: "Kilometre",
                    placeholder: "150.000",
                    text: $viewModel.mileage,
                    keyboardType: .numberPad
                )
                .onChange(of: viewModel.mileage) { _, newValue in
                    viewModel.formatMileageInput(newValue)
                }

                inputField(
                    title: "İşçilik Ücreti",
                    placeholder: "0",
                    text: $viewModel.laborFee,
                    keyboardType: .numberPad
                )
                .onChange(of: viewModel.laborFee) { _, newValue in
                    viewModel.formatLaborFeeInput(newValue)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Notlar")
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 90)
                    .padding(12)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var quickJobsSection: some View {
        let isComplete = !viewModel.selectedQuickJobs.isEmpty

        return formSection(title: "Parça / İşlemler", subtitle: "Kategori seçerek hızlı ekleyin veya elle girin", step: 2, isComplete: isComplete) {
            
            // Kategori chip'leri — web'deki gibi horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Button(category) {
                            viewModel.toggleCategory(category)
                        }
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.category == category
                                ? Color(red: 0.94, green: 0.75, blue: 0.20)
                                : Color.white
                        )
                        .foregroundStyle(
                            viewModel.category == category
                                ? Color.black.opacity(0.85)
                                : Color.primary
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    viewModel.category == category
                                        ? Color.clear
                                        : Color.gray.opacity(0.25),
                                    lineWidth: 1
                                )
                        )
                        .animation(.easeInOut(duration: 0.15), value: viewModel.category)
                    }
                }
                .padding(.horizontal, 1)
            }

            // Hızlı seçim — horizontal scroll
            if let quickJobs = viewModel.quickJobs[viewModel.category], !quickJobs.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("HIZLI SEÇİM")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickJobs, id: \.self) { quickJob in
                                quickJobChip(quickJob)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }

            // Seçilen kalemler
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.selectedQuickJobs.isEmpty {
                    // Web'deki dashed empty state
                    HStack(spacing: 10) {
                        Image(systemName: "circle.dotted")
                            .foregroundStyle(.secondary.opacity(0.4))
                        Text("Kategori seçerek veya aşağıdan hızlı işlem ekleyin.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                Color.gray.opacity(0.25),
                                style: StrokeStyle(lineWidth: 1, dash: [5])
                            )
                    )
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.selectedQuickJobs) { item in
                            selectedJobRow(item)
                        }
                    }

                    // Toplam özeti
                    if viewModel.grandTotal > 0 {
                        VStack(spacing: 8) {
                            amountRow(title: "Parça / Malzeme", value: viewModel.partsTotal)

                            if viewModel.laborFeeValue > 0 {
                                amountRow(title: "İşçilik", value: viewModel.laborFeeValue)
                            }

                            Rectangle()
                                .fill(Color(red: 0.88, green: 0.72, blue: 0.18).opacity(0.3))
                                .frame(height: 0.5)

                            HStack {
                                Text("Genel Toplam")
                                    .font(.subheadline.weight(.bold))
                                Spacer()
                                Text(viewModel.grandTotal.formattedCurrency)
                                    .font(.headline.weight(.bold))
                            }
                        }
                        .padding(14)
                        .background(Color(red: 0.99, green: 0.96, blue: 0.86))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color(red: 0.94, green: 0.75, blue: 0.20).opacity(0.4), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }

                // + Ekle butonu — web'deki gibi altta tam genişlik
                Button {
                    viewModel.addEmptyQuickJob()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.bold))
                        Text("Ekle")
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.gray.opacity(0.20), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var imagesSection: some View {
        let remaining = 5 - viewModel.attachments.count
        let isComplete = !viewModel.attachments.isEmpty

        return formSection(title: "Görseller", subtitle: "Opsiyonel • En Fazla 5 Görsel", step: 3, isComplete: isComplete) {
            Button {
                isPresentingImagePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.subheadline)
                    Text(remaining > 0 ? "Görsel Seç (\(remaining) kaldı)" : "Limit doldu")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(remaining > 0 ? Color(red: 0.97, green: 0.97, blue: 0.96) : Color.gray.opacity(0.08))
                .foregroundStyle(remaining > 0 ? .primary : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(remaining <= 0)

            if !viewModel.attachments.isEmpty {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    ForEach(viewModel.attachments) { attachment in
                        ZStack(alignment: .topTrailing) {
                            if let image = UIImage(data: attachment.data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 88)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }

                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.removeAttachment(id: attachment.id)
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.black.opacity(0.60))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(5)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerButtons: some View {
        let emailVerified = appState.currentUser?.emailVerified == true
        let canSave = viewModel.canSubmit && emailVerified

        return VStack(spacing: 8) {
            // Uyarı — neden disabled
            if !emailVerified {
                HStack(spacing: 6) {
                    Image(systemName: "envelope.badge")
                        .font(.caption)
                    Text("Kaydetmek için e-postanızı doğrulayın.")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity, alignment: .center)
            } else if !viewModel.canSubmit {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption)
                    Text("İşlem başlığı gerekli.")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack(spacing: 12) {
                Button("İptal") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    Task {
                        let didSave = await viewModel.save()
                        if didSave {
                            didCreateJob?()
                            dismiss()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isSaving {
                            ProgressView().tint(.white)
                        }
                        Text(viewModel.isSaving ? "Kaydediliyor..." : "İşlemi Kaydet")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(canSave ? Color.black.opacity(0.86) : Color.gray.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(viewModel.isSaving || !canSave)
                .animation(.easeInOut(duration: 0.2), value: canSave)
            }
        }
    }

    // MARK: - Reusable Components

    private func formSection<Content: View>(
        title: String,
        subtitle: String,
        step: Int,
        isComplete: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isComplete
                                ? Color.green.opacity(0.15)
                                : Color(red: 0.94, green: 0.75, blue: 0.20)
                        )
                        .frame(width: 26, height: 26)

                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.green)
                    } else {
                        Text("\(step)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.black.opacity(0.80))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isComplete)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            content()
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func selectedJobRow(_ item: JobQuickItem) -> some View {
        VStack(spacing: 0) {
            // Başlık satırı
            HStack(spacing: 8) {
                TextField("İşlem Adı", text: Binding(
                    get: { item.name },
                    set: { viewModel.updateQuickJob(id: item.id, name: $0) }
                ))
                .textFieldStyle(.plain)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.removeQuickJob(id: item.id)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // Ayraç
            Rectangle()
                .fill(Color.gray.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 12)
                .padding(.top, 10)

            // Marka / Adet / Birim fiyat
            HStack(spacing: 0) {
                metricField(
                    label: "MARKA",
                    placeholder: "Opsiyonel",
                    text: Binding(
                        get: { item.brand },
                        set: { viewModel.updateQuickJob(id: item.id, brand: $0) }
                    )
                )

                metricDivider()

                metricField(
                    label: "ADET",
                    placeholder: "1",
                    text: Binding(
                        get: { item.quantity == 0 ? "" : String(item.quantity) },
                        set: { viewModel.updateQuickJob(id: item.id, quantity: Int($0) ?? 0) }
                    ),
                    keyboardType: .numberPad
                )

                metricDivider()

                metricField(
                    label: "BİRİM FİYAT",
                    placeholder: "0 ₺",
                    text: Binding(
                        get: { item.unitPrice == 0 ? "" : String(Int(item.unitPrice)) },
                        set: { viewModel.updateQuickJob(id: item.id, unitPrice: Double($0) ?? 0) }
                    ),
                    keyboardType: .numberPad
                )
            }
            .padding(.top, 10)

            // Toplam — sadece > 0 ise
            if item.lineTotal > 0 {
                Rectangle()
                    .fill(Color.gray.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                HStack {
                    Text("Satır Toplamı")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(item.lineTotal.formattedCurrency)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.14, green: 0.13, blue: 0.11))
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
            }

            Spacer().frame(height: 12)
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.10), lineWidth: 1)
        )
    }

    // Yardımcı — metric hücre
    private func metricField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .kerning(0.4)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    // Yardımcı — dikey ayraç
    private func metricDivider() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.12))
            .frame(width: 1, height: 44)
    }

    private func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(title)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func infoCard(icon: String, title: String, message: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(color.opacity(0.80))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.20), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func amountRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.formattedCurrency)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func quickJobChip(_ quickJob: String) -> some View {
        let isSelected = viewModel.selectedQuickJobs.contains(where: { $0.name == quickJob })

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if let selectedItem = viewModel.selectedQuickJobs.first(where: { $0.name == quickJob }) {
                    viewModel.removeQuickJob(id: selectedItem.id)
                } else {
                    viewModel.addQuickJob(named: quickJob)
                }
            }
        } label: {
            Text(quickJob)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    isSelected
                        ? Color.black.opacity(0.86)
                        : Color(red: 0.97, green: 0.97, blue: 0.96)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color.gray.opacity(0.18),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Extensions & Helpers

#Preview {
    NavigationStack {
        NewJobView(vehicleId: "preview")
            .environmentObject(AppState())
    }
}

private struct MultiImagePicker: UIViewControllerRepresentable {
    let maxSelectionCount: Int
    let onPick: ([Data]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = maxSelectionCount
        configuration.filter = .images

        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: ([Data]) -> Void

        init(onPick: @escaping ([Data]) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            Task {
                var pickedImages: [Data] = []

                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self),
                       let image = try? await result.itemProvider.loadImage(),
                       let data = image.jpegData(compressionQuality: 0.85) {
                        pickedImages.append(data)
                    }
                }

                await MainActor.run {
                    onPick(pickedImages)
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
