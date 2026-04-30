import SwiftUI

struct JobDetailSheetView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: JobDetailViewModel
    @State private var isPresentingImagePicker = false
    @State private var previewImage: JobDetailPreviewImage?

    init(
        job: JobListItem,
        businessId: String,
        vehicleId: String,
        service: VehicleService = .shared,
        onJobUpdated: @escaping (JobListItem) -> Void
    ) {
        self._vm = StateObject(wrappedValue: JobDetailViewModel(
            job: job,
            businessId: businessId,
            vehicleId: vehicleId,
            service: service,
            onJobUpdated: onJobUpdated
        ))
    }

    // MARK: - Body

    //VIEW MINIMAL
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                JobDetailSummarySection(job: vm.job)

                if !vm.items.isEmpty || vm.currentLaborFee > 0 {
                    JobDetailItemsSection(
                        items: vm.items,
                        currentLaborFee: vm.currentLaborFee,
                        grandTotal: vm.grandTotal
                    )
                }

                if vm.hasAnyImages || vm.isEditMode {
                    JobDetailImagesSection(
                        images: $vm.images,
                        newImages: vm.newImages,
                        isEditMode: vm.isEditMode,
                        allImagesCount: vm.allImagesCount,
                        fileError: vm.fileError,
                        onAddTapped: {
                            isPresentingImagePicker = true
                        },
                        onRemoveRemote: { index in
                            vm.removeRemoteImage(at: index)
                        },
                        onRemoveLocal: { id in
                            vm.removeLocalImage(id)
                        },
                        onPreviewRemote: { url in
                            previewImage = JobDetailPreviewImage(url: url)
                        },
                        onPreviewLocal: { image in
                            previewImage = JobDetailPreviewImage(image: image)
                        }
                    )
                }

                if vm.isEditMode && !vm.isCompleted {
                    JobDetailEditSection(
                        vm: vm,
                        onCancel: {
                            withAnimation {
                                vm.cancelEditing()
                            }
                        },
                        onSave: {
                            Task {
                                await vm.saveChanges()
                            }
                        }
                    )
                }
                JobDetailHeaderView(
                    vm: vm,
                    onDismissRequested: {
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("İşlem Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Kapat") { dismiss() }
                    .foregroundStyle(.primary)
            }
        }
        .sheet(isPresented: $isPresentingImagePicker) {
            JobMultiImagePicker(maxSelectionCount: max(0, 5 - vm.allImagesCount)) { images in
                vm.appendImages(images)
            }
        }
        .sheet(item: $previewImage) { image in
            JobDetailImagePreviewSheet(image: image)
        }
    }
}

#Preview {
    VehicleListView()
        .environmentObject(AppState())
}
