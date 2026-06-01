//
//  VehicleEditSheetView.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct VehicleEditSheetView: View {

    @ObservedObject var viewModel: VehicleDetailViewModel

    @Binding var isPresented: Bool

    let screenBackground: Color

    @State private var validationShake = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    if viewModel.editErrors.hasErrors {
                        FormValidationBanner(
                            message: "Kırmızı ile işaretli alanları kontrol edin."
                        )
                    }

                    AppTextField(
                        title: "Araç Sahibi",
                        placeholder: "Ad Soyad",
                        text: $viewModel.ownerName,
                        error: viewModel.editErrors.ownerName
                    )
                    .id(FormFieldAnchor.ownerName.rawValue)

                    AppTextField(
                        title: "Telefon",
                        placeholder: "0555 123 45 67",
                        text: $viewModel.ownerPhone,
                        keyboardType: .phonePad,
                        error: viewModel.editErrors.ownerPhone
                    )
                    .id(FormFieldAnchor.ownerPhone.rawValue)

                    AppTextField(
                        title: "Motor Hacmi",
                        placeholder: viewModel.fuelType == .electric
                            ? "Elektrikli araçta geçerli değil"
                            : "1.6",
                        text: $viewModel.engineSize,
                        keyboardType: .decimalPad,
                        error: viewModel.editErrors.engineSize,
                        isDisabled: viewModel.fuelType == .electric
                    )
                    .id(FormFieldAnchor.engineSize.rawValue)

                    AppTextField(
                        title: "Şasi No",
                        placeholder: "17 karakter",
                        text: $viewModel.chassisNo,
                        error: viewModel.editErrors.chassisNo
                    )
                    .id(FormFieldAnchor.chassisNo.rawValue)

                    AppTextField(
                        title: "Model Yılı",
                        placeholder: "2024",
                        text: $viewModel.year,
                        keyboardType: .numberPad,
                        error: viewModel.editErrors.year
                    )
                    .id(FormFieldAnchor.year.rawValue)

                    fuelTypeSection

                    FormTextEditor(
                        title: "Notlar",
                        text: $viewModel.notes,
                        error: viewModel.editErrors.notes,
                        minHeight: 120
                    )
                    .id(FormFieldAnchor.notes.rawValue)
                    .onChange(of: viewModel.notes) { _, newValue in
                        if newValue.count > FieldValidator.maxNotesLength {
                            viewModel.notes = String(newValue.prefix(FieldValidator.maxNotesLength))
                        }
                    }

                    actionButtons
                }
                .padding(16)
                .shake(trigger: validationShake)
            }
            .formScrollFocus(anchor: viewModel.focusFieldAnchor, proxy: proxy)
        }
        .background(screenBackground)
    }
}

// MARK: Extensions

extension VehicleEditSheetView {

    fileprivate var fuelTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Yakıt Tipi")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Yakıt Tipi", selection: $viewModel.fuelType) {
                ForEach(VehicleFuelType.allCases) { fuelType in
                    Text(fuelType.title)
                        .tag(fuelType)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    fileprivate var actionButtons: some View {
        HStack(spacing: 12) {

            Button("Vazgeç") {
                isPresented = false
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.black.opacity(0.05))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )

            Button {
                Task {
                    let didSave = await viewModel.saveVehicleChanges()

                    if didSave {
                        isPresented = false
                    } else if viewModel.editErrors.hasErrors {
                        validationShake += 1
                    }
                }
            } label: {
                HStack(spacing: 8) {

                    if viewModel.isSaving {
                        ButtonLoadingSkeleton()
                    }

                    Text(
                        viewModel.isSaving
                            ? "Kaydediliyor..."
                            : "Kaydet"
                    )
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(Color.black.opacity(0.86))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .disabled(viewModel.isSaving)
        }
    }
}
