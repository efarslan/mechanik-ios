//
//  JobDetailViewModel.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI
import Combine
import UIKit

@MainActor
final class JobDetailViewModel: ObservableObject {

    struct FormErrors {
        var title: String?
        var laborFee: String?
        var notes: String?
        var quickJobs: String?

        var hasErrors: Bool {
            title != nil || laborFee != nil || notes != nil || quickJobs != nil
        }

        var firstInvalidAnchor: FormFieldAnchor? {
            if title != nil { return .jobTitle }
            if laborFee != nil { return .jobLaborFee }
            if notes != nil { return .jobNotes }
            if quickJobs != nil { return .jobQuickJobs }
            return nil
        }
    }

    // MARK: - Input Models
    let job: JobListItem
    let businessId: String
    let vehicleId: String
    let service: VehicleService
    let onJobUpdated: (JobListItem) -> Void

    // MARK: - UI State
    @Published var isEditMode = false
    @Published var title: String
    @Published var notes: String
    @Published var laborFeeText: String
    @Published var items: [JobQuickItem]
    @Published var images: [String]
    @Published var newImages: [PickedImage] = []

    @Published var isSaving = false
    @Published var errors = FormErrors()
    @Published var focusFieldAnchor: FormFieldAnchor?
    @Published var fileError: String?

    @Published var showDeleteConfirmation = false
    @Published var showCompleteConfirmation = false

    // MARK: - Derived UI State
    var hasAnyImages: Bool {
        !images.isEmpty || !newImages.isEmpty
    }

    // MARK: - Init
    init(
        job: JobListItem,
        businessId: String,
        vehicleId: String,
        service: VehicleService,
        onJobUpdated: @escaping (JobListItem) -> Void
    ) {
        self.job = job
        self.businessId = businessId
        self.vehicleId = vehicleId
        self.service = service
        self.onJobUpdated = onJobUpdated

        self.title = job.title
        self.notes = job.notes ?? ""
        let fee = job.laborFee ?? 0
        self.laborFeeText = fee == 0 ? "" : String(Int(fee))

        self.items = job.selectedQuickJobs
        self.images = job.imageUrls
    }

    // MARK: - Computed

    var currentLaborFee: Double {
        parsedLaborFee
    }

    var partsTotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var grandTotal: Double {
        partsTotal + currentLaborFee
    }

    var allImagesCount: Int {
        images.count + newImages.count
    }

    var quickJobNames: [String] {
        JobQuickJobCatalog.allNames
    }
    
    private var parsedLaborFee: Double {
        Double(laborFeeText) ?? 0
    }

    var isCompleted: Bool {
        job.status == .completed
    }

    var isCancelled: Bool {
        job.status == .cancelled
    }

    var statusTitle: String {
        job.status.title
    }

    var statusColor: Color {
        switch job.status {
        case .active: return .green
        case .completed: return .secondary
        case .cancelled: return .red
        }
    }

    // MARK: - Actions

    func resetEditState() {
        title = job.title
        notes = job.notes ?? ""
        let fee = job.laborFee ?? 0
        laborFeeText = fee == 0 ? "" : String(Int(fee))

        items = job.selectedQuickJobs
        images = job.imageUrls
        newImages = []

        errors = FormErrors()
        fileError = nil
        showDeleteConfirmation = false
        showCompleteConfirmation = false
    }

    func toggleEditMode() {
        isEditMode.toggle()
        if !isEditMode {
            resetEditState()
        }
    }

    func cancelEditing() {
        resetEditState()
        isEditMode = false
    }

    func confirmCancellationFlow() {
        showDeleteConfirmation = true
        showCompleteConfirmation = false
    }

    func confirmCompletionFlow() {
        showCompleteConfirmation = true
        showDeleteConfirmation = false
    }

    func clearStatusConfirmations() {
        showDeleteConfirmation = false
        showCompleteConfirmation = false
    }

    func addEmptyQuickJob() {
        items.append(JobQuickItem(name: "", brand: "", quantity: 1, unitPrice: 0))
    }

    func removeQuickJob(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    func appendImages(_ dataList: [Data]) {
        let remainingSlots = max(0, 5 - allImagesCount)

        guard remainingSlots > 0 else {
            fileError = "En fazla 5 görsel ekleyebilirsiniz."
            return
        }

        for (index, data) in dataList.enumerated() {
            guard index < remainingSlots else {
                fileError = "En fazla 5 görsel ekleyebilirsiniz."
                break
            }

            if let image = UIImage(data: data) {
                newImages.append(PickedImage(data: data, image: image))
            }
        }

        fileError = nil
    }

    func removeRemoteImage(at index: Int) {
        guard images.indices.contains(index) else { return }
        images.remove(at: index)
        fileError = nil
    }

    func removeLocalImage(_ id: UUID) {
        newImages.removeAll { $0.id == id }
        fileError = nil
    }

    @discardableResult
    func validate() -> FormErrors {
        var nextErrors = FormErrors()

        nextErrors.title = FieldValidator.jobTitleError(title)
        nextErrors.laborFee = FieldValidator.laborFeeError(parsedLaborFee)
        nextErrors.notes = FieldValidator.notesError(notes)
        nextErrors.quickJobs = quickJobsValidationError()

        errors = nextErrors
        focusFieldAnchor = nextErrors.firstInvalidAnchor
        return nextErrors
    }

    var canSave: Bool {
        FieldValidator.jobTitleError(title) == nil
            && FieldValidator.laborFeeError(parsedLaborFee) == nil
            && FieldValidator.notesError(notes) == nil
            && quickJobsValidationError() == nil
    }

    @discardableResult
    func saveChanges() async -> Bool {
        let validationResult = validate()
        guard !validationResult.hasErrors else { return false }

        isSaving = true

        do {
            let uploadedURLs = try await service.uploadJobImages(
                businessId: businessId,
                vehicleId: vehicleId,
                images: newImages.map(\.data)
            )

            let finalImages = images + uploadedURLs
            let filteredItems = items.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            let laborFee = parsedLaborFee

            try await service.updateJob(
                id: job.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
                laborFee: laborFee,
                selectedQuickJobs: filteredItems,
                imageUrls: finalImages
            )

            let updated = JobListItem(
                id: job.id,
                vehicleId: vehicleId,
                title: title,
                status: job.status,
                createdAt: job.createdAt,
                updatedAt: Date(),
                category: job.category,
                mileage: job.mileage,
                notes: notes.isEmpty ? nil : notes,
                laborFee: laborFee,
                selectedQuickJobs: filteredItems,
                imageUrls: finalImages
            )

            onJobUpdated(updated)

            images = finalImages
            newImages = []
            isEditMode = false
            return true

        } catch {
            fileError = "İşlem güncellenirken hata oluştu."
        }

        isSaving = false
        return false
    }

    private func quickJobsValidationError() -> String? {
        for item in items {
            let trimmedName = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { continue }

            if let nameError = FieldValidator.quickJobNameError(item.name) {
                return nameError
            }
            if let quantityError = FieldValidator.quickJobQuantityError(item.quantity, hasName: true) {
                return quantityError
            }
            if let priceError = FieldValidator.quickJobUnitPriceError(item.unitPrice, hasName: true) {
                return priceError
            }
        }
        return nil
    }

    @discardableResult
    func updateStatus(_ status: JobStatus) async -> Bool {
        isSaving = true

        do {
            try await service.updateJobStatus(id: job.id, status: status.rawValue)

            let updated = JobListItem(
                id: job.id,
                vehicleId: vehicleId,
                title: job.title,
                status: status,
                createdAt: job.createdAt,
                updatedAt: Date(),
                category: job.category,
                mileage: job.mileage,
                notes: job.notes,
                laborFee: job.laborFee,
                selectedQuickJobs: job.selectedQuickJobs,
                imageUrls: job.imageUrls
            )

            onJobUpdated(updated)
            isSaving = false
            return true

        } catch {
            fileError = "Durum güncellenemedi."
        }

        isSaving = false
        return false
    }
}
