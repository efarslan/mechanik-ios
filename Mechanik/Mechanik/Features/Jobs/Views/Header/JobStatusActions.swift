//
//  JobStatusActions.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobStatusActions: View {
    @ObservedObject var vm: JobDetailViewModel
    let onDismissRequested: () -> Void
    
    @ViewBuilder
    var body: some View {
        if !vm.isCompleted {
            VStack(spacing: 10) {

                HStack(spacing: 10) {

                    if vm.isCancelled {
                        statusButton(
                            "Geri Al",
                            "arrow.uturn.left",
                            .green
                        ) {
                            Task { await vm.updateStatus(.active) }
                        }
                    } else {
                        statusButton(
                            vm.showDeleteConfirmation ? "Silmeyi Onayla" : "İşlemi Sil",
                            vm.showDeleteConfirmation ? "checkmark" : "trash",
                            .red
                        ) {
                            if vm.showDeleteConfirmation {
                                Task {
                                    let didUpdate = await vm.updateStatus(.cancelled)
                                    if didUpdate { onDismissRequested() }
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    vm.confirmCancellationFlow()
                                }
                            }
                        }
                    }

                    statusButton(
                        vm.showCompleteConfirmation ? "Onayla" : "Tamamlandı",
                        vm.showCompleteConfirmation ? "checkmark.circle.fill" : "checkmark.circle",
                        .green
                    ) {
                        if vm.showCompleteConfirmation {
                            Task {
                                let didUpdate = await vm.updateStatus(.completed)
                                if didUpdate { onDismissRequested() }
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.confirmCompletionFlow()
                            }
                        }
                    }
                }

                if vm.showDeleteConfirmation || vm.showCompleteConfirmation {
                    Button("Vazgeç") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.clearStatusConfirmations()
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statusButton(_ title: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(vm.isSaving)
    }
}
