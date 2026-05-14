import Foundation

struct SettingsBusiness {
    let id: String
    let name: String
    let ownerId: String
    let inviteCode: String
}

struct TeamMember: Identifiable {
    let id: String
    let name: String?
    let email: String?
    let role: String
    let status: String

    var displayName: String {
        if let name, !name.isEmpty {
            return name
        }
        if let email, !email.isEmpty {
            return email
        }
        return id
    }
}

struct SettingsAlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
