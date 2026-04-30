import Combine
import Foundation

@MainActor
final class VehicleDetailViewModel: ObservableObject {

    enum JobStatusFilter: String, CaseIterable, Identifiable {
        case all
        case active
        case completed
        case cancelled

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all:
                return "Tümü"
            case .active:
                return "Aktif"
            case .completed:
                return "Tamamlandı"
            case .cancelled:
                return "Silindi"
            }
        }
    }

    enum SortDirection {
        case newestFirst
        case oldestFirst
    }

    struct EditFormErrors {
        var ownerName: String?
        var ownerPhone: String?
        var engineSize: String?
        var chassisNo: String?
        var year: String?

        var hasErrors: Bool {
            ownerName != nil || ownerPhone != nil || engineSize != nil || chassisNo != nil || year != nil
        }
    }

    @Published private(set) var vehicle: Vehicle?
    @Published private(set) var brandLogoURL: String?
    @Published private(set) var jobs: [JobListItem] = []
    @Published private(set) var jobStats = VehicleJobStats(total: 0, active: 0, completed: 0)
    @Published private(set) var access: BusinessAccess?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var statusFilter: JobStatusFilter = .all
    @Published var sortDirection: SortDirection = .newestFirst

    @Published var ownerName: String = ""
    @Published var ownerPhone: String = ""
    @Published var engineSize: String = ""
    @Published var chassisNo: String = ""
    @Published var year: String = ""
    @Published var fuelType: VehicleFuelType = .gasoline
    @Published var notes: String = ""
    @Published var editErrors = EditFormErrors()

    private let vehicleService: VehicleService
    private let businessService: BusinessService
    private var currentVehicleId: String?
    private var currentUser: User?

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

    var canEditVehicle: Bool {
        access?.canCreateVehicle == true
    }

    var filteredJobs: [JobListItem] {
        var list = jobs

        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            list = list.filter {
                $0.title.lowercased().contains(query)
                    || ($0.notes ?? "").lowercased().contains(query)
            }
        }

        switch statusFilter {
        case .all:
            break
        case .active:
            list = list.filter { $0.status == .active }
        case .completed:
            list = list.filter { $0.status == .completed }
        case .cancelled:
            list = list.filter { $0.status == .cancelled }
        }

        return list.sorted { lhs, rhs in
            let lhsDate = lhs.createdAt ?? .distantPast
            let rhsDate = rhs.createdAt ?? .distantPast
            return sortDirection == .newestFirst ? lhsDate > rhsDate : lhsDate < rhsDate
        }
    }

    func load(user: User?, vehicleId: String) async {
        guard let user else {
            errorMessage = "Giriş gerekli."
            return
        }

        isLoading = true
        errorMessage = nil
        currentVehicleId = vehicleId
        currentUser = user

        do {
            guard let access = try await businessService.fetchBusinessAccess(userId: user.id, email: user.email) else {
                errorMessage = "İşletme bulunamadı."
                isLoading = false
                return
            }

            self.access = access

            async let vehicleTask = vehicleService.fetchVehicle(id: vehicleId, businessId: access.businessId)
            async let jobsTask = vehicleService.fetchJobs(vehicleId: vehicleId, includeCancelled: true)
            async let statsTask = vehicleService.fetchJobStats(vehicleId: vehicleId)

            guard let fetchedVehicle = try await vehicleTask else {
                errorMessage = "Araç bulunamadı."
                isLoading = false
                return
            }

            vehicle = fetchedVehicle
            brandLogoURL = try await vehicleService.fetchBrandLogoURL(brandName: fetchedVehicle.brand)
            jobs = try await jobsTask
            jobStats = try await statsTask
            populateEditFields()
        } catch {
            errorMessage = "Araç detayları yüklenirken bir hata oluştu."
        }

        isLoading = false
    }

    func reload() async {
        guard let currentUser, let currentVehicleId else { return }
        await load(user: currentUser, vehicleId: currentVehicleId)
    }

    func saveVehicleChanges() async -> Bool {
        guard let vehicle, canEditVehicle else {
            errorMessage = "Bu işlem için yetkiniz yok."
            return false
        }

        let validationResult = validateEditForm()
        guard !validationResult.hasErrors else {
            return false
        }

        guard let yearValue = Int(year.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Model yılı geçersiz."
            return false
        }

        isSaving = true
        errorMessage = nil

        let payload = VehicleUpdatePayload(
            ownerName: ownerName.trimmingCharacters(in: .whitespacesAndNewlines),
            ownerPhone: normalizedOptional(ownerPhone),
            engineSize: fuelType == .electric ? nil : normalizedOptional(engineSize),
            chassisNo: normalizedOptional(chassisNo)?.uppercased(),
            year: yearValue,
            fuelType: fuelType.rawValue,
            notes: normalizedOptional(notes)
        )

        do {
            try await vehicleService.updateVehicle(id: vehicle.id, payload: payload)

            self.vehicle?.ownerName = payload.ownerName
            self.vehicle?.ownerPhone = payload.ownerPhone
            self.vehicle?.engineSize = payload.engineSize
            self.vehicle?.chassisNo = payload.chassisNo
            self.vehicle?.year = payload.year
            self.vehicle?.fuelType = payload.fuelType
            self.vehicle?.notes = payload.notes

            isSaving = false
            return true
        } catch {
            errorMessage = "Araç bilgileri güncellenemedi."
            isSaving = false
            return false
        }
    }

    func populateEditFields() {
        guard let vehicle else { return }

        ownerName = vehicle.ownerName
        ownerPhone = vehicle.ownerPhone ?? ""
        engineSize = vehicle.engineSize ?? ""
        chassisNo = vehicle.chassisNo ?? ""
        year = vehicle.year == 0 ? "" : String(vehicle.year)
        fuelType = VehicleFuelType(storageValue: vehicle.fuelType)
        notes = vehicle.notes ?? ""
        editErrors = EditFormErrors()
    }

    @discardableResult
    func validateEditForm() -> EditFormErrors {
        var errors = EditFormErrors()
        let trimmedOwnerName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = ownerPhone.replacingOccurrences(of: "[\\s()-]", with: "", options: .regularExpression)
        let trimmedYear = year.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEngine = engineSize.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedChassis = chassisNo.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let currentYear = Calendar.current.component(.year, from: Date())

        if trimmedOwnerName.isEmpty {
            errors.ownerName = "Araç sahibi zorunludur."
        }

        if !trimmedPhone.isEmpty,
           trimmedPhone.range(of: #"^(\+90|0)?[5][0-9]{9}$"#, options: .regularExpression) == nil {
            errors.ownerPhone = "Geçerli telefon numarası giriniz."
        }

        if trimmedYear.range(of: #"^\d{4}$"#, options: .regularExpression) == nil {
            errors.year = "4 haneli model yılı giriniz."
        } else if let yearValue = Int(trimmedYear), yearValue < 1930 || yearValue > currentYear + 1 {
            errors.year = "Model yılı 1930-\(currentYear + 1) arasında olmalı."
        }

        if fuelType != .electric,
           !trimmedEngine.isEmpty,
           trimmedEngine.range(of: #"^\d\.\d{1,2}$"#, options: .regularExpression) == nil {
            errors.engineSize = "Geçerli format: 1.6"
        }

        if !trimmedChassis.isEmpty {
            if trimmedChassis.count != 17 {
                errors.chassisNo = "Şasi numarası 17 karakter olmalı."
            } else if trimmedChassis.range(of: #"[IOQ]"#, options: .regularExpression) != nil {
                errors.chassisNo = "Şasi numarasında I, O, Q kullanılamaz."
            }
        }

        editErrors = errors
        return errors
    }

    private func normalizedOptional(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
