import Combine
import Foundation

@MainActor
final class NewJobViewModel: ObservableObject {

    struct FormErrors {
        var title: String?
        var mileage: String?
        var laborFee: String?
        var notes: String?
        var quickJobs: String?

        var hasErrors: Bool {
            title != nil
                || mileage != nil
                || laborFee != nil
                || notes != nil
                || quickJobs != nil
        }

        var firstInvalidAnchor: FormFieldAnchor? {
            if title != nil { return .jobTitle }
            if mileage != nil { return .jobMileage }
            if laborFee != nil { return .jobLaborFee }
            if notes != nil { return .jobNotes }
            if quickJobs != nil { return .jobQuickJobs }
            return nil
        }
    }
    
    struct JobImageAttachment: Identifiable, Hashable {
        let id = UUID()
        let data: Data
    }
    
    @Published var title: String = ""
    @Published var category: String = ""
    @Published var mileage: String = ""
    @Published var notes: String = ""
    @Published var laborFee: String = ""
    @Published var selectedQuickJobs: [JobQuickItem] = []
    @Published private(set) var attachments: [JobImageAttachment] = []
    @Published private(set) var access: BusinessAccess?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSaving: Bool = false
    @Published var errors = FormErrors()
    @Published var focusFieldAnchor: FormFieldAnchor?
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    
    let categories = JobQuickJobCatalog.categories
    
    let quickJobs = JobQuickJobCatalog.jobsByCategory
            
    private let vehicleService: VehicleService
    private let businessService: BusinessService
    private var vehicleId: String?
    init(
        vehicleService: VehicleService? = nil,
        businessService: BusinessService? = nil
    ) {
        self.vehicleService = vehicleService ?? .shared
        self.businessService = businessService ?? BusinessService()
    }

    var canCreateJob: Bool {
        access?.canCreateJob == true
    }

    var canSubmit: Bool {
        canCreateJob && !hasValidationErrors
    }

    private var hasValidationErrors: Bool {
        FieldValidator.jobTitleError(title) != nil
            || FieldValidator.mileageError(mileageValue: normalizedMileage) != nil
            || FieldValidator.laborFeeError(laborFeeValue) != nil
            || FieldValidator.notesError(notes) != nil
            || quickJobsValidationError() != nil
    }

    var partsTotal: Double {
        selectedQuickJobs.reduce(0) { $0 + $1.lineTotal }
    }

    var laborFeeValue: Double {
        Double(laborFee.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var grandTotal: Double {
        partsTotal + laborFeeValue
    }

    func load(user: User?, vehicleId: String) async {
        guard let user else {
            errorMessage = "Giriş Gerekli."
            return
        }

        isLoading = true
        errorMessage = nil
        infoMessage = nil
        self.vehicleId = vehicleId

        do {
            access = try await businessService.fetchBusinessAccess(userId: user.id, email: user.email, name: user.name)

            if access == nil {
                errorMessage = "İşletme Bulunamadı."
            } else if !user.emailVerified {
                infoMessage = "Yeni işlem oluşturma, e-posta doğrulaması tamamlanana kadar kısıtlıdır."
            } else if !canCreateJob {
                infoMessage = "Yeni işlem sadece owner, manager veya teknisyen rolleri için açıktır."
            }
        } catch {
            errorMessage = "Yeni işlem formu yüklenemedi."
        }

        isLoading = false
    }

    func toggleCategory(_ value: String) {
        category = category == value ? "" : value
    }

    func addQuickJob(named name: String) {
        guard !selectedQuickJobs.contains(where: { $0.name == name }) else { return }
        selectedQuickJobs.append(JobQuickItem(name: name, brand: "", quantity: 1, unitPrice: 0))
    }

    func addEmptyQuickJob() {
        selectedQuickJobs.append(JobQuickItem(name: "", brand: "", quantity: 1, unitPrice: 0))
    }

    func removeQuickJob(id: UUID) {
        selectedQuickJobs.removeAll { $0.id == id }
    }

    func updateQuickJob(id: UUID, name: String? = nil, brand: String? = nil, quantity: Int? = nil, unitPrice: Double? = nil) {
        guard let index = selectedQuickJobs.firstIndex(where: { $0.id == id }) else { return }

        if let name {
            selectedQuickJobs[index].name = name
        }
        if let brand {
            selectedQuickJobs[index].brand = brand
        }
        if let quantity {
            selectedQuickJobs[index].quantity = quantity
        }
        if let unitPrice {
            selectedQuickJobs[index].unitPrice = unitPrice
        }
    }

    func formatMileageInput(_ value: String) {
        let digits = value.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        mileage = digits.isEmpty ? "" : (Int(digits) ?? 0).formatted(.number.locale(Locale(identifier: "tr_TR")))
    }

    func formatLaborFeeInput(_ value: String) {
        let digits = value.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        laborFee = digits.isEmpty ? "" : (Int(digits) ?? 0).formatted(.number.locale(Locale(identifier: "tr_TR")))
    }

    func appendImages(_ images: [Data]) {
        guard !images.isEmpty else { return }

        for data in images {
            guard attachments.count < 5 else {
                errorMessage = "En Fazla 5 Görsel Ekleyebilirsiniz."
                break
            }

            attachments.append(JobImageAttachment(data: data))
        }
    }

    func removeAttachment(id: UUID) {
        attachments.removeAll { $0.id == id }
    }

    @discardableResult
    func validate() -> FormErrors {
        var nextErrors = FormErrors()

        nextErrors.title = FieldValidator.jobTitleError(title)
        nextErrors.mileage = FieldValidator.mileageError(mileageValue: normalizedMileage)
        nextErrors.laborFee = FieldValidator.laborFeeError(laborFeeValue)
        nextErrors.notes = FieldValidator.notesError(notes)
        nextErrors.quickJobs = quickJobsValidationError()

        errors = nextErrors
        focusFieldAnchor = nextErrors.firstInvalidAnchor
        return nextErrors
    }

    func save() async -> Bool {
        guard let access, let vehicleId, canCreateJob else {
            errorMessage = "Bu işlem için yetkiniz yok."
            return false
        }

        let validationResult = validate()
        guard !validationResult.hasErrors else {
            return false
        }

        guard let mileageValue = normalizedMileage else {
            errorMessage = "Kilometre geçersiz."
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            let imageURLs = try await vehicleService.uploadJobImages(
                businessId: access.businessId,
                vehicleId: vehicleId,
                images: attachments.map(\.data)
            )

            let payload = NewJobPayload(
                businessId: access.businessId,
                vehicleId: vehicleId,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.isEmpty ? nil : category,
                mileage: mileageValue,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
                laborFee: laborFeeValue,
                selectedQuickJobs: selectedQuickJobs.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                imageUrls: imageURLs
            )

            _ = try await vehicleService.createJob(payload)
            isSaving = false
            return true
        } catch {
            errorMessage = "İşlem kaydedilirken hata oluştu."
            isSaving = false
            return false
        }
    }

    private var normalizedMileage: Int? {
        let digits = mileage.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
        return Int(digits)
    }

    private func quickJobsValidationError() -> String? {
        for item in selectedQuickJobs {
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
}
