import SwiftUI

struct NewVehicleView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = NewVehicleViewModel()
    @State private var hasLoaded = false
    let didCreateVehicle: (() -> Void)?

    init(didCreateVehicle: (() -> Void)? = nil) {
        self.didCreateVehicle = didCreateVehicle
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    formContent
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            .navigationTitle("Araç Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Geri")
                        }
                    }
                }
            }
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await viewModel.load(user: appState.currentUser)
            }
            .onChange(of: viewModel.brandId) { _, _ in
                Task {
                    await viewModel.loadModelsIfNeeded()
                }
            }
        }
    }

    private var formContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    messageCard(title: "Bir sorun var", message: errorMessage, color: .red)
                }

                if let infoMessage = viewModel.infoMessage {
                    messageCard(title: "Bilgi", message: infoMessage, color: .orange)
                }

                vehicleInfoSection
                ownerSection
                notesSection
                footerButtons
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private var vehicleInfoSection: some View {
        formSection(title: "Araç Bilgileri", subtitle: "Plaka, marka, model ve teknik detaylar", step: 1) {
            textField(
                title: "Plaka",
                placeholder: "34ABC123",
                text: $viewModel.plate,
                error: viewModel.errors.plate
            )
            .onChange(of: viewModel.plate) { _, newValue in
                viewModel.plate = newValue
                    .replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
                    .uppercased()
                    .prefix(8)
                    .description
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Marka")

                Menu {
                    ForEach(viewModel.brands) { brand in
                        Button(brand.name) {
                            viewModel.handleBrandChange(brand.id)
                        }
                    }
                } label: {
                    pickerLabel(
                        title: viewModel.brands.first(where: { $0.id == viewModel.brandId })?.name ?? "Marka Seçin",
                        isSelected: !viewModel.brandId.isEmpty
                    )
                }

                fieldError(viewModel.errors.brand)
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Model")

                Menu {
                    ForEach(viewModel.models, id: \.self) { model in
                        Button(model) {
                            viewModel.model = model
                        }
                    }
                } label: {
                    pickerLabel(
                        title: viewModel.model.isEmpty ? (viewModel.brandId.isEmpty ? "Önce Marka Seçin" : "Model Seçin") : viewModel.model,
                        isSelected: !viewModel.model.isEmpty
                    )
                }
                .disabled(viewModel.brandId.isEmpty)

                fieldError(viewModel.errors.model)
            }

            textField(
                title: "Model Yılı",
                placeholder: "\(viewModel.minYear)-\(viewModel.maxYear)",
                text: $viewModel.year,
                keyboardType: .numberPad,
                error: viewModel.errors.year
            )
            .onChange(of: viewModel.year) { _, newValue in
                viewModel.year = newValue.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
                    .prefix(4)
                    .description
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Yakıt Tipi")

                Picker("Yakıt Tipi", selection: $viewModel.fuelType) {
                    ForEach(VehicleFuelType.allCases) { fuelType in
                        Text(fuelType.title).tag(fuelType)
                    }
                }
                .pickerStyle(.segmented)
            }

            if !viewModel.shouldHideEngineSize {
                textField(
                    title: "Motor Hacmi",
                    placeholder: "Ornek: 1.6",
                    text: $viewModel.engineSize,
                    keyboardType: .decimalPad,
                    error: viewModel.errors.engineSize
                )
                .onChange(of: viewModel.engineSize) { _, newValue in
                    let digits = newValue.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
                    if digits.isEmpty {
                        viewModel.engineSize = ""
                    } else if digits.count == 1 {
                        viewModel.engineSize = digits
                    } else {
                        viewModel.engineSize = "\(digits.prefix(1)).\(digits.dropFirst().prefix(2))"
                    }
                }
            }

            textField(
                title: "Şasi No",
                placeholder: "17 karakter",
                text: $viewModel.chassisNo,
                error: viewModel.errors.chassisNo
            )
            .onChange(of: viewModel.chassisNo) { _, newValue in
                viewModel.chassisNo = newValue.uppercased().prefix(17).description
            }
        }
    }

    private var ownerSection: some View {
        formSection(title: "Araç Sahibi", subtitle: "İletişim bilgileri", step: 2) {
            textField(
                title: "Ad Soyad",
                placeholder: "Araç sahibinin adı",
                text: $viewModel.ownerName,
                error: viewModel.errors.ownerName
            )

            textField(
                title: "Telefon",
                placeholder: "0555 123 45 67",
                text: $viewModel.ownerPhone,
                keyboardType: .phonePad,
                error: viewModel.errors.ownerPhone
            )
        }
    }

    private var notesSection: some View {
        formSection(title: "Notlar", subtitle: "Araç hakkında ek bilgi", step: 3) {
            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Not")

                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var footerButtons: some View {
        VStack(spacing: 12) {
            if viewModel.errors.hasErrors {
                messageCard(title: "Eksik alanlar var", message: "Lütfen zorunlu alanları kontrol edin.", color: .red)
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
                        let saveSucceeded = await viewModel.save()
                        if saveSucceeded {
                            didCreateVehicle?()
                            dismiss()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(viewModel.isSaving ? "Kaydediliyor..." : "Araç Oluştur")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(viewModel.canCreateVehicle && appState.currentUser?.emailVerified == true ? Color.black.opacity(0.86) : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(viewModel.isSaving || !viewModel.canCreateVehicle || appState.currentUser?.emailVerified != true)
            }
        }
    }

    private func formSection<Content: View>(title: String, subtitle: String, step: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(step)")
                    .font(.caption.weight(.bold))
                    .frame(width: 24, height: 24)
                    .background(Color(red: 0.94, green: 0.75, blue: 0.20))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
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
    }

    private func textField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        error: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(error == nil ? Color.clear : Color.red.opacity(0.4), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            fieldError(error)
        }
    }

    private func pickerLabel(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(isSelected ? Color.black.opacity(0.82) : .secondary)

            Spacer()

            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func messageCard(title: String, message: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)

            Text(message)
                .font(.footnote)
                .foregroundStyle(color.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func fieldError(_ message: String?) -> some View {
        Group {
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    NewVehicleView()
        .environmentObject(AppState())
}
