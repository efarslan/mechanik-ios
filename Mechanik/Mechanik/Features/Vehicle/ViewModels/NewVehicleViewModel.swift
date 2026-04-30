import Combine
import Foundation

@MainActor
final class NewVehicleViewModel: ObservableObject {

    struct FormErrors {
        var plate: String?
        var brand: String?
        var model: String?
        var year: String?
        var engineSize: String?
        var ownerName: String?
        var ownerPhone: String?
        var chassisNo: String?

        var hasErrors: Bool {
            plate != nil
                || brand != nil
                || model != nil
                || year != nil
                || engineSize != nil
                || ownerName != nil
                || ownerPhone != nil
                || chassisNo != nil
        }
    }

    @Published var plate: String = ""
    @Published var brandId: String = ""
    @Published var model: String = ""
    @Published var year: String = ""
    @Published var fuelType: VehicleFuelType = .gasoline
    @Published var engineSize: String = ""
    @Published var chassisNo: String = ""
    @Published var ownerName: String = ""
    @Published var ownerPhone: String = ""
    @Published var notes: String = ""

    @Published private(set) var brands: [VehicleBrand] = []
    @Published private(set) var models: [String] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSaving: Bool = false
    @Published private(set) var access: VehicleCreateAccess?
    @Published var errors = FormErrors()
    @Published var infoMessage: String?
    @Published var errorMessage: String?

    let minYear = 1930
    let maxYear = Calendar.current.component(.year, from: Date()) + 1

    private let vehicleService: VehicleService
    private let businessService: BusinessService

    init(
        vehicleService: VehicleService? = nil,
        businessService: BusinessService? = nil
    ) {
        self.vehicleService = vehicleService ?? .shared
        self.businessService = businessService ?? BusinessService()
    }

    var canCreateVehicle: Bool {
        access?.canCreateVehicle == true
    }

    var shouldHideEngineSize: Bool {
        fuelType == .electric
    }

    func load(user: User?) async {
        guard let user else {
            errorMessage = "Giriş gerekli."
            return
        }

        isLoading = true
        errorMessage = nil
        infoMessage = nil

        do {
            async let brandsTask = vehicleService.fetchBrands()
            async let accessTask = businessService.fetchVehicleCreateAccess(userId: user.id, email: user.email)

            brands = try await brandsTask
            access = try await accessTask

            if access == nil {
                errorMessage = "İşletme Bulunamadı."
            } else if !user.emailVerified {
                infoMessage = "Yeni araç oluşturma, e-posta doğrulaması tamamlanana kadar kısıtlıdır."
            } else if !canCreateVehicle {
                infoMessage = "Yeni araç ekleme sadece owner veya manager yetkisi ile yapılabilir."
            }
        } catch {
            errorMessage = "Form verileri yüklenirken bir hata oluştu."
        }

        isLoading = false
    }

    func handleBrandChange(_ brandId: String) {
        self.brandId = brandId
        model = ""
        models = []
    }

    func loadModelsIfNeeded() async {
        guard !brandId.isEmpty else {
            models = []
            return
        }

        do {
            models = try await vehicleService.fetchModels(brandId: brandId)
        } catch {
            errorMessage = "Modeller yüklenemedi."
        }
    }

    func validate() -> FormErrors {
        var nextErrors = FormErrors()
        let normalizedPlate = plate.replacingOccurrences(of: " ", with: "").uppercased()
        let trimmedYear = year.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEngineSize = engineSize.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedChassisNo = chassisNo.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedPhone = ownerPhone.replacingOccurrences(of: "[\\s()-]", with: "", options: .regularExpression)

        if normalizedPlate.isEmpty {
            nextErrors.plate = "Plaka zorunludur."
        } else if normalizedPlate.range(of: #"^\d{2}[A-Z]{1,3}\d{2,4}$"#, options: .regularExpression) == nil {
            nextErrors.plate = "Geçerli plaka giriniz. Örnek: 34ABC123"
        }

        if brandId.isEmpty {
            nextErrors.brand = "Marka Seçiniz."
        }

        if model.isEmpty {
            nextErrors.model = "Model Seçiniz."
        }

        if trimmedYear.isEmpty {
            nextErrors.year = "Model yılı zorunludur."
        } else if trimmedYear.range(of: #"^\d{4}$"#, options: .regularExpression) == nil {
            nextErrors.year = "4 haneli yıl giriniz."
        } else if let yearValue = Int(trimmedYear), yearValue < minYear || yearValue > maxYear {
            nextErrors.year = "Yıl \(minYear)-\(maxYear) arasında olmalıdır."
        }

        if !shouldHideEngineSize {
            if trimmedEngineSize.isEmpty {
                nextErrors.engineSize = "Motor hacmi zorunludur."
            } else if trimmedEngineSize.range(of: #"^\d\.\d{1,2}$"#, options: .regularExpression) == nil {
                nextErrors.engineSize = "Ondalıklı format kullanın. Ornek: 1.6"
            }
        }

        if !trimmedChassisNo.isEmpty {
            if trimmedChassisNo.count != 17 {
                nextErrors.chassisNo = "Şasi numarası tam 17 karakter olmalıdır."
            } else if trimmedChassisNo.range(of: #"[IOQ]"#, options: .regularExpression) != nil {
                nextErrors.chassisNo = "Şasi numarasında I, O ve Q kullanilamaz."
            } else if trimmedChassisNo.range(of: #"^[A-HJ-NPR-Z0-9]{17}$"#, options: .regularExpression) == nil {
                nextErrors.chassisNo = "Şasi numarası sadece harf ve rakam içermelidir."
            }
        }

        if ownerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nextErrors.ownerName = "Araç sahibi adı zorunludur."
        }

        if !normalizedPhone.isEmpty,
           normalizedPhone.range(of: #"^(\+90|0)?[5][0-9]{9}$"#, options: .regularExpression) == nil {
            nextErrors.ownerPhone = "Geçerli telefon numarası giriniz."
        }

        errors = nextErrors
        return nextErrors
    }

    func save() async -> Bool {
        errorMessage = nil

        guard let access, canCreateVehicle else {
            errorMessage = "Bu işlem için yetkiniz yok."
            return false
        }

        let validationResult = validate()
        guard !validationResult.hasErrors else {
            return false
        }

        guard let selectedBrand = brands.first(where: { $0.id == brandId }),
              let yearValue = Int(year.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Araç bilgileri geçersiz."
            return false
        }

        isSaving = true

        let vehicle = Vehicle(
            id: "",
            businessId: access.businessId,
            plate: plate.replacingOccurrences(of: " ", with: "").uppercased(),
            brand: selectedBrand.name,
            model: model,
            year: yearValue,
            fuelType: fuelType.rawValue,
            engineSize: shouldHideEngineSize ? nil : engineSize.trimmingCharacters(in: .whitespacesAndNewlines),
            chassisNo: chassisNo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : chassisNo.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
            ownerName: ownerName.trimmingCharacters(in: .whitespacesAndNewlines),
            ownerPhone: ownerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : ownerPhone.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: nil
        )

        do {
            _ = try await vehicleService.createVehicle(vehicle)
            isSaving = false
            return true
        } catch {
            errorMessage = "Araç eklenirken hata oluştu."
            isSaving = false
            return false
        }
    }
}
