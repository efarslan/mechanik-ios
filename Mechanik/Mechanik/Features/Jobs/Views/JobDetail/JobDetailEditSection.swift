//
//  JobDetailEditSection.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobDetailEditSection: View {

    @ObservedObject var vm: JobDetailViewModel

    let onCancel: () -> Void
    let onSave: () -> Void

    @State private var validationShake = 0
    
    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            sectionHeader

            if vm.errors.hasErrors {
                FormValidationBanner(
                    message: "Kırmızı ile işaretli alanları kontrol edin."
                )
            }

            titleSection

            itemsSection

            laborFeeSection

            actionButtons
        }
        .shake(trigger: validationShake)
    }
}
// MARK: - Sections

private extension JobDetailEditSection {

    var sectionHeader: some View {
        Text("DÜZENLEME")
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
            .padding(.bottom, 6)
    }

    var titleSection: some View {

        VStack(spacing: 0) {

            mobileField(label: "Başlık", error: vm.errors.title) {
                TextField("Başlık", text: $vm.title)
            }
            .id(FormFieldAnchor.jobTitle.rawValue)

            Divider()
                .padding(.leading, 16)

            mobileField(label: "Notlar", error: vm.errors.notes) {
                TextEditor(text: $vm.notes)
                    .frame(minHeight: 80)
            }
            .id(FormFieldAnchor.jobNotes.rawValue)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    var itemsSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {

                Text("Parça / İşlem")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    vm.addEmptyQuickJob()
                } label: {

                    Label("Ekle", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if let quickJobsError = vm.errors.quickJobs {
                FormErrorText(message: quickJobsError)
                    .id(FormFieldAnchor.jobQuickJobs.rawValue)
            }

            ForEach(Array(vm.items.enumerated()), id: \.offset) { index, _ in
                JobDetailEditItemCard(
                    item: $vm.items[index],
                    allQuickJobNames: vm.quickJobNames,
                    onRemove: {
                        withAnimation {
                            vm.removeQuickJob(at: index)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Labor Fee Section
    var laborFeeSection: some View {

        VStack(spacing: 0) {

            mobileField(label: "İşçilik Ücreti", error: vm.errors.laborFee) {

                HStack {

                    TextField(
                        "0",
                        text: $vm.laborFeeText
                    )
                    .keyboardType(.numberPad)

                    Text("₺")
                        .foregroundStyle(.tertiary)
                }
            }
            .id(FormFieldAnchor.jobLaborFee.rawValue)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    var actionButtons: some View {

        HStack(spacing: 12) {

            Button("Vazgeç") {
                onCancel()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(.secondarySystemFill))
            .foregroundStyle(.primary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )

            Button {
                _ = vm.validate()
                if vm.errors.hasErrors {
                    validationShake += 1
                } else {
                    onSave()
                }
            } label: {

                HStack(spacing: 8) {

                    if vm.isSaving {
                        ButtonLoadingSkeleton()
                    }

                    Text(
                        vm.isSaving
                        ? "Kaydediliyor..."
                        : "Kaydet"
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.primary)
                .foregroundStyle(Color(.systemBackground))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                )
            }
            .disabled(vm.isSaving)
            .opacity(
                vm.isSaving ? 0.5 : 1
            )
        }
    }
}

// MARK: - Helper

private extension JobDetailEditSection {

    func mobileField<Content: View>(
        label: String,
        error: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isInvalid = error != nil

        return VStack(alignment: .leading, spacing: 6) {

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isInvalid ? InvalidFieldStyle.labelColor : .secondary)

            content()
                .padding(10)
                .invalidFieldBorder(isInvalid: isInvalid, cornerRadius: 10)

            FormErrorText(message: error)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
