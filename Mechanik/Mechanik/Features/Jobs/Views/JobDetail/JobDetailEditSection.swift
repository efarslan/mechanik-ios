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
    
    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            sectionHeader

            titleSection

            itemsSection

            laborFeeSection

            actionButtons
        }
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

            mobileField(label: "Başlık") {
                TextField("Başlık", text: $vm.title)
            }

            Divider()
                .padding(.leading, 16)

            mobileField(label: "Notlar") {
                TextEditor(text: $vm.notes)
                    .frame(minHeight: 80)
            }
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

            mobileField(label: "İşçilik Ücreti") {

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
                onSave()
            } label: {

                HStack(spacing: 8) {

                    if vm.isSaving {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
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
            .disabled(
                vm.isSaving
                || vm.title
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )
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
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
