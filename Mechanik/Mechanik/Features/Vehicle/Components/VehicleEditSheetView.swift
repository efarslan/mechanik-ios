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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                if viewModel.editErrors.hasErrors {
                    FeedbackStateView(
                        icon: "exclamationmark.circle",
                        title: "Eksik veya hatalı alan var",
                        message: "Lütfen alanları kontrol edin."
                    )
                }

                AppInputField(
                    title: "Araç Sahibi",
                    placeholder: "Ad Soyad",
                    text: $viewModel.ownerName,
                    error: viewModel.editErrors.ownerName
                )

                AppInputField(
                    title: "Telefon",
                    placeholder: "0555 123 45 67",
                    text: $viewModel.ownerPhone,
                    keyboardType: .phonePad,
                    error: viewModel.editErrors.ownerPhone
                )

                AppInputField(
                    title: "Motor Hacmi",
                    placeholder: viewModel.fuelType == .electric
                        ? "Elektrikli araçta geçerli değil"
                        : "1.6",
                    text: $viewModel.engineSize,
                    keyboardType: .decimalPad,
                    error: viewModel.editErrors.engineSize,
                    isDisabled: viewModel.fuelType == .electric
                )

                AppInputField(
                    title: "Şasi No",
                    placeholder: "17 karakter",
                    text: $viewModel.chassisNo,
                    error: viewModel.editErrors.chassisNo
                )

                AppInputField(
                    title: "Model Yılı",
                    placeholder: "2024",
                    text: $viewModel.year,
                    keyboardType: .numberPad,
                    error: viewModel.editErrors.year
                )

                fuelTypeSection

                notesSection

                actionButtons
            }
            .padding(16)
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

    fileprivate var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notlar")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 120)
                .padding(12)
                .background(
                    Color(
                        red: 0.97,
                        green: 0.97,
                        blue: 0.96
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
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
                    }
                }
            } label: {
                HStack(spacing: 8) {

                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
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
