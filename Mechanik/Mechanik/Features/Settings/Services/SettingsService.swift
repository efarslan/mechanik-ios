import Foundation
import FirebaseAuth
import FirebaseFirestore

final class SettingsService {

    private let db = Firestore.firestore()
    private let authService: FirebaseAuthService
    private let businessService: BusinessService

    init(
        authService: FirebaseAuthService = .shared,
        businessService: BusinessService = BusinessService()
    ) {
        self.authService = authService
        self.businessService = businessService
    }

    func fetchAccess(userId: String, email: String, name: String?) async throws -> BusinessAccess? {
        try await businessService.fetchBusinessAccess(userId: userId, email: email, name: name)
    }

    func fetchBusiness(businessId: String) async throws -> SettingsBusiness? {
        let snapshot = try await db.collection("businesses").document(businessId).getDocument()
        guard snapshot.exists, let data = snapshot.data() else { return nil }

        return SettingsBusiness(
            id: snapshot.documentID,
            name: data["name"] as? String ?? "İşletme",
            ownerId: data["ownerId"] as? String ?? "",
            inviteCode: data["inviteCode"] as? String ?? ""
        )
    }

    func createBusiness(name: String, user: User) async throws {
        let inviteCode = Self.generateInviteCode()
        let businessRef = db.collection("businesses").document()

        try await businessRef.setData([
            "name": name,
            "ownerId": user.id,
            "inviteCode": inviteCode,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ])

        var memberData: [String: Any] = [
            "userId": user.id,
            "role": "owner",
            "status": "active",
            "email": user.email,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let memberName = user.name?.trimmingCharacters(in: .whitespacesAndNewlines), !memberName.isEmpty {
            memberData["name"] = memberName
        }

        try await businessRef.collection("members").document(user.id).setData(memberData, merge: true)
    }

    func updateBusinessName(businessId: String, name: String) async throws {
        try await db.collection("businesses").document(businessId).updateData([
            "name": name,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func refreshInviteCode(businessId: String) async throws -> String {
        let newCode = Self.generateInviteCode()
        try await db.collection("businesses").document(businessId).updateData([
            "inviteCode": newCode,
            "updatedAt": FieldValue.serverTimestamp()
        ])
        return newCode
    }

    func resetPassword(email: String) async throws {
        try await authService.sendPasswordReset(email: email)
    }

    func resendEmailVerification() async throws {
        try await authService.sendEmailVerification()
    }

    func removeMember(businessId: String, memberId: String, by actorId: String) async throws {
        try await db.collection("businesses")
            .document(businessId)
            .collection("members")
            .document(memberId)
            .updateData([
                "status": "inactive",
                "deactivatedAt": FieldValue.serverTimestamp(),
                "deactivatedBy": actorId,
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }

    func approveMember(businessId: String, memberId: String, by actorId: String) async throws {
        try await db.collection("businesses")
            .document(businessId)
            .collection("members")
            .document(memberId)
            .updateData([
                "status": "active",
                "approvedAt": FieldValue.serverTimestamp(),
                "approvedBy": actorId,
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }

    func rejectMember(businessId: String, memberId: String, by actorId: String) async throws {
        try await db.collection("businesses")
            .document(businessId)
            .collection("members")
            .document(memberId)
            .updateData([
                "status": "inactive",
                "rejectedAt": FieldValue.serverTimestamp(),
                "rejectedBy": actorId,
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }

    func updateMemberRole(businessId: String, memberId: String, role: String, by actorId: String) async throws {
        try await db.collection("businesses")
            .document(businessId)
            .collection("members")
            .document(memberId)
            .updateData([
                "role": role,
                "updatedAt": FieldValue.serverTimestamp(),
                "updatedBy": actorId
            ])
    }

    func observeMembers(
        businessId: String,
        onChanged: @escaping ([TeamMember], [TeamMember]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        db.collection("businesses")
            .document(businessId)
            .collection("members")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onError(error)
                    return
                }

                guard let snapshot else {
                    onChanged([], [])
                    return
                }

                let members: [TeamMember] = snapshot.documents.map { doc in
                    let data = doc.data()
                    return TeamMember(
                        id: doc.documentID,
                        name: data["name"] as? String,
                        email: data["email"] as? String,
                        role: data["role"] as? String ?? "technician",
                        status: data["status"] as? String ?? "active"
                    )
                }

                onChanged(
                    members.filter { $0.status == "active" },
                    members.filter { $0.status == "pending" }
                )
            }
    }

    private static func generateInviteCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let raw = String((0..<8).compactMap { _ in chars.randomElement() })
        return "\(raw.prefix(4))-\(raw.suffix(4))"
    }
}
