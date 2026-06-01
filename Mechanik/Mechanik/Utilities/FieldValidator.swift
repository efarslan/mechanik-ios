import Foundation

enum FieldValidator {

    // MARK: - Constants

    static let businessNameLengthRange = 3...50
    static let minVehicleYear = 1930
    static let maxNotesLength = 2000
    static let maxJobTitleLength = 120
    static let maxOwnerNameLength = 100
    static let minMileage = 1
    static let maxMileage = 9_999_999
    static let maxLaborFee: Double = 99_999_999
    static let maxUnitPrice: Double = 99_999_999
    static let maxQuickJobQuantity = 9_999

    private static let allowedBusinessNameCharacters = CharacterSet.letters
        .union(.decimalDigits)
        .union(CharacterSet(charactersIn: "."))

    // MARK: - Auth

    static func nameError(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Ad soyad zorunludur."
        }
        if trimmed.count < 2 {
            return "Ad soyad en az 2 karakter olmalıdır."
        }
        if trimmed.count > maxOwnerNameLength {
            return "Ad soyad en fazla \(maxOwnerNameLength) karakter olabilir."
        }
        return nil
    }

    static func emailError(_ email: String) -> String? {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.isEmpty {
            return "E-posta adresi zorunludur."
        }
        if normalized.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) == nil {
            return "Geçerli bir e-posta adresi girin."
        }
        return nil
    }

    static func passwordError(_ password: String, isRegister: Bool) -> String? {
        if password.isEmpty {
            return "Şifre zorunludur."
        }
        guard isRegister else { return nil }

        if password.count < 8 {
            return "Şifre en az 8 karakter olmalıdır."
        }
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            return "Şifre en az bir büyük harf içermelidir."
        }
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            return "Şifre en az bir rakam içermelidir."
        }
        return nil
    }

    static func confirmPasswordError(password: String, confirmPassword: String) -> String? {
        if confirmPassword.isEmpty {
            return "Şifre tekrarı zorunludur."
        }
        if password != confirmPassword {
            return "Şifreler eşleşmiyor."
        }
        return nil
    }

    // MARK: - Business

    static func filteredBusinessName(_ name: String) -> String {
        let allowedScalars = name.unicodeScalars.filter {
            allowedBusinessNameCharacters.contains($0)
        }
        let filteredName = String(String.UnicodeScalarView(allowedScalars))
        guard filteredName.count > businessNameLengthRange.upperBound else { return filteredName }
        return String(filteredName.prefix(businessNameLengthRange.upperBound))
    }

    static func businessNameError(_ name: String) -> String? {
        let trimmed = filteredBusinessName(name.trimmingCharacters(in: .whitespacesAndNewlines))
        if trimmed.isEmpty {
            return "İşletme adı zorunludur."
        }
        if !businessNameLengthRange.contains(trimmed.count) {
            return "İşletme adı 3-50 karakter olmalı; sadece harf, rakam ve nokta içerebilir."
        }
        return nil
    }

    // MARK: - Vehicle

    static func plateError(_ plate: String) -> String? {
        let normalized = plate.replacingOccurrences(of: " ", with: "").uppercased()
        if normalized.isEmpty {
            return "Plaka zorunludur."
        }
        if normalized.range(of: #"^\d{2}[A-Z]{1,3}\d{2,4}$"#, options: .regularExpression) == nil {
            return "Geçerli plaka giriniz. Örnek: 34ABC123"
        }
        return nil
    }

    static func yearError(_ year: String, minYear: Int = minVehicleYear, maxYear: Int? = nil) -> String? {
        let trimmed = year.trimmingCharacters(in: .whitespacesAndNewlines)
        let upperBound = maxYear ?? Calendar.current.component(.year, from: Date()) + 1

        if trimmed.isEmpty {
            return "Model yılı zorunludur."
        }
        if trimmed.range(of: #"^\d{4}$"#, options: .regularExpression) == nil {
            return "4 haneli yıl giriniz."
        }
        if let yearValue = Int(trimmed), yearValue < minYear || yearValue > upperBound {
            return "Yıl \(minYear)-\(upperBound) arasında olmalıdır."
        }
        return nil
    }

    static func engineSizeError(_ engineSize: String, required: Bool) -> String? {
        let trimmed = engineSize.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return required ? "Motor hacmi zorunludur." : nil
        }
        if trimmed.range(of: #"^\d\.\d{1,2}$"#, options: .regularExpression) == nil {
            return "Ondalıklı format kullanın. Örnek: 1.6"
        }
        return nil
    }

    static func chassisError(_ chassis: String) -> String? {
        let trimmed = chassis.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return nil }

        if trimmed.count != 17 {
            return "Şasi numarası tam 17 karakter olmalıdır."
        }
        if trimmed.range(of: #"[IOQ]"#, options: .regularExpression) != nil {
            return "Şasi numarasında I, O ve Q kullanılamaz."
        }
        if trimmed.range(of: #"^[A-HJ-NPR-Z0-9]{17}$"#, options: .regularExpression) == nil {
            return "Şasi numarası sadece harf ve rakam içermelidir."
        }
        return nil
    }

    static func ownerNameError(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Araç sahibi adı zorunludur."
        }
        if trimmed.count > maxOwnerNameLength {
            return "Ad en fazla \(maxOwnerNameLength) karakter olabilir."
        }
        return nil
    }

    static func phoneError(_ phone: String) -> String? {
        let normalized = phone.replacingOccurrences(of: "[\\s()-]", with: "", options: .regularExpression)
        guard !normalized.isEmpty else { return nil }

        if normalized.range(of: #"^(\+90|0)?[5][0-9]{9}$"#, options: .regularExpression) == nil {
            return "Geçerli telefon numarası giriniz."
        }
        return nil
    }

    static func notesError(_ notes: String) -> String? {
        if notes.count > maxNotesLength {
            return "Notlar en fazla \(maxNotesLength) karakter olabilir."
        }
        return nil
    }

    // MARK: - Job

    static func jobTitleError(_ title: String) -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "İşlem başlığı zorunludur."
        }
        if trimmed.count > maxJobTitleLength {
            return "Başlık en fazla \(maxJobTitleLength) karakter olabilir."
        }
        return nil
    }

    static func mileageError(mileageValue: Int?) -> String? {
        guard let mileageValue else {
            return "Kilometre zorunludur."
        }
        if mileageValue < minMileage {
            return "Kilometre en az \(minMileage) olmalıdır."
        }
        if mileageValue > maxMileage {
            return "Kilometre en fazla \(maxMileage.formatted()) olabilir."
        }
        return nil
    }

    static func laborFeeError(_ value: Double) -> String? {
        if value < 0 {
            return "İşçilik ücreti negatif olamaz."
        }
        if value > maxLaborFee {
            return "İşçilik ücreti çok yüksek."
        }
        return nil
    }

    static func quickJobNameError(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.count > maxJobTitleLength {
            return "İşlem adı en fazla \(maxJobTitleLength) karakter olabilir."
        }
        return nil
    }

    static func quickJobQuantityError(_ quantity: Int, hasName: Bool) -> String? {
        guard hasName else { return nil }
        if quantity < 1 {
            return "Adet en az 1 olmalıdır."
        }
        if quantity > maxQuickJobQuantity {
            return "Adet en fazla \(maxQuickJobQuantity) olabilir."
        }
        return nil
    }

    static func quickJobUnitPriceError(_ unitPrice: Double, hasName: Bool) -> String? {
        guard hasName else { return nil }
        if unitPrice < 0 {
            return "Birim fiyat negatif olamaz."
        }
        if unitPrice > maxUnitPrice {
            return "Birim fiyat çok yüksek."
        }
        return nil
    }
}
