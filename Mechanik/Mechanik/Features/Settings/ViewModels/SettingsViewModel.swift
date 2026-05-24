import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published private(set) var isLoading = false
    @Published private(set) var business: SettingsBusiness?
    @Published private(set) var access: BusinessAccess?
    @Published private(set) var activeMembers: [TeamMember] = []
    @Published private(set) var pendingMembers: [TeamMember] = []

    @Published var businessNameDraft = "" {
        didSet {
            let filteredName = Self.filteredBusinessName(businessNameDraft)
            if filteredName != businessNameDraft {
                businessNameDraft = filteredName
            }
        }
    }
    @Published var newBusinessName = "" {
        didSet {
            let filteredName = Self.filteredBusinessName(newBusinessName)
            if filteredName != newBusinessName {
                newBusinessName = filteredName
            }
        }
    }
    @Published var pendingRoles: [String: String] = [:]

    @Published var resetPasswordMessage: SettingsAlertMessage?
    @Published var infoMessage: SettingsAlertMessage?
    @Published var errorMessage: SettingsAlertMessage?

    @Published var isCreatingBusiness = false
    @Published var isSavingName = false
    @Published var isSavingRoles = false
    @Published var isRefreshingInviteCode = false
    @Published var isSendingPasswordReset = false

    private static let businessNameLengthRange = 3...50
    private static let allowedBusinessNameCharacters = CharacterSet.letters
        .union(.decimalDigits)
        .union(CharacterSet(charactersIn: "."))

    private let service: SettingsService
    private var currentUser: User?
    private var memberListener: ListenerRegistration?

    init(service: SettingsService? = nil) {
        self.service = service ?? SettingsService()
    }

    deinit {
        memberListener?.remove()
    }

    var canManageStaff: Bool {
        access?.role == "owner" || access?.role == "manager"
    }

    var canEditBusinessName: Bool {
        access?.role == "owner"
    }

    var hasPendingRoleChanges: Bool {
        !pendingRoles.isEmpty
    }

    var shouldShowVerificationBanner: Bool {
        currentUser?.emailVerified == false
    }

    func load(user: User?) async {
        guard let user else { return }
        currentUser = user
        isLoading = true

        do {
            let access = try await service.fetchAccess(userId: user.id, email: user.email, name: user.name)
            self.access = access

            guard let businessId = access?.businessId else {
                self.business = nil
                self.businessNameDraft = ""
                memberListener?.remove()
                memberListener = nil
                isLoading = false
                return
            }

            let business = try await service.fetchBusiness(businessId: businessId)
            self.business = business
            self.businessNameDraft = business?.name ?? ""
            observeMembersIfNeeded(user: user)
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Ayarlar yüklenemedi.")
        }

        isLoading = false
    }

    func createBusiness(user: User?) async {
        guard let user else { return }
        let name = normalizedBusinessName(newBusinessName)
        newBusinessName = name
        guard Self.businessNameLengthRange.contains(name.count) else {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "İşletme adı 3-50 karakter olmalı; sadece harf, rakam ve nokta içerebilir.")
            return
        }

        isCreatingBusiness = true
        defer { isCreatingBusiness = false }

        do {
            try await service.createBusiness(name: name, user: user)
            newBusinessName = ""
            await load(user: user)
            infoMessage = SettingsAlertMessage(title: "Başarılı", message: "İşletme oluşturuldu.")
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "İşletme oluşturulamadı.")
        }
    }

    func saveBusinessName() async {
        guard canEditBusinessName, let business else { return }
        let name = normalizedBusinessName(businessNameDraft)
        businessNameDraft = name
        guard Self.businessNameLengthRange.contains(name.count) else {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "İşletme adı 3-50 karakter olmalı; sadece harf, rakam ve nokta içerebilir.")
            return
        }
        guard name != business.name else { return }

        isSavingName = true
        defer { isSavingName = false }

        do {
            try await service.updateBusinessName(businessId: business.id, name: name)
            self.business = SettingsBusiness(id: business.id, name: name, ownerId: business.ownerId, inviteCode: business.inviteCode)
            infoMessage = SettingsAlertMessage(title: "Başarılı", message: "İşletme adı güncellendi.")
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "İşletme adı güncellenemedi.")
        }
    }

    func refreshInviteCode() async {
        guard access?.role == "owner", let business else { return }
        isRefreshingInviteCode = true
        defer { isRefreshingInviteCode = false }

        do {
            let code = try await service.refreshInviteCode(businessId: business.id)
            self.business = SettingsBusiness(id: business.id, name: business.name, ownerId: business.ownerId, inviteCode: code)
            infoMessage = SettingsAlertMessage(title: "Başarılı", message: "Davet kodu yenilendi.")
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Davet kodu yenilenemedi.")
        }
    }

    func sendPasswordReset(email: String) async {
        isSendingPasswordReset = true
        defer { isSendingPasswordReset = false }

        do {
            try await service.resetPassword(email: email)

            resetPasswordMessage = SettingsAlertMessage(
                title: "Başarılı",
                message: "Şifre sıfırlama e-postası gönderildi."
            )

        } catch {
            errorMessage = SettingsAlertMessage(
                title: "Hata",
                message: "Şifre sıfırlama e-postası gönderilemedi."
            )
        }
    }

    func resendVerificationEmail() async {
        do {
            try await service.resendEmailVerification()
            infoMessage = SettingsAlertMessage(title: "Başarılı", message: "Doğrulama e-postası gönderildi.")
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Doğrulama e-postası gönderilemedi.")
        }
    }

    func saveRoleChanges(actorId: String) async {
        guard let business else { return }
        isSavingRoles = true
        defer { isSavingRoles = false }

        do {
            for (memberId, role) in pendingRoles {
                try await service.updateMemberRole(businessId: business.id, memberId: memberId, role: role, by: actorId)
            }
            pendingRoles = [:]
            infoMessage = SettingsAlertMessage(title: "Başarılı", message: "Rol değişiklikleri kaydedildi.")
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Rol değişiklikleri kaydedilemedi.")
        }
    }

    func removeMember(_ member: TeamMember, actorId: String) async {
        guard let business, member.role != "owner" else { return }
        do {
            try await service.removeMember(businessId: business.id, memberId: member.id, by: actorId)
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Çalışan kaldırılamadı.")
        }
    }

    func approveMember(_ member: TeamMember, actorId: String) async {
        guard let business else { return }
        do {
            try await service.approveMember(businessId: business.id, memberId: member.id, by: actorId)
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Başvuru onaylanamadı.")
        }
    }

    func rejectMember(_ member: TeamMember, actorId: String) async {
        guard let business else { return }
        do {
            try await service.rejectMember(businessId: business.id, memberId: member.id, by: actorId)
        } catch {
            errorMessage = SettingsAlertMessage(title: "Hata", message: "Başvuru reddedilemedi.")
        }
    }

    func updatePendingRole(memberId: String, role: String, currentRole: String) {
        guard role != currentRole else {
            pendingRoles.removeValue(forKey: memberId)
            return
        }
        pendingRoles[memberId] = role
    }

    func discardPendingRoles() {
        pendingRoles = [:]
    }

    private static func filteredBusinessName(_ name: String) -> String {
        let allowedScalars = name.unicodeScalars.filter {
            allowedBusinessNameCharacters.contains($0)
        }
        let filteredName = String(String.UnicodeScalarView(allowedScalars))
        guard filteredName.count > businessNameLengthRange.upperBound else { return filteredName }
        return String(filteredName.prefix(businessNameLengthRange.upperBound))
    }

    private func normalizedBusinessName(_ name: String) -> String {
        Self.filteredBusinessName(name.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func observeMembersIfNeeded(user: User) {
        guard canManageStaff, user.emailVerified, let business else {
            memberListener?.remove()
            memberListener = nil
            activeMembers = []
            pendingMembers = []
            return
        }

        memberListener?.remove()
        memberListener = service.observeMembers(
            businessId: business.id,
            onChanged: { [weak self] active, pending in
                guard let self else { return }
                self.activeMembers = active
                self.pendingMembers = pending
            },
            onError: { [weak self] _ in
                Task { @MainActor in
                    self?.errorMessage = SettingsAlertMessage(title: "Hata", message: "Çalışan listesi alınamadı.")
                }
            }
        )
    }
}
