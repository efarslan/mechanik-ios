//
//  BusinessService.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import Foundation
import FirebaseFirestore

final class BusinessService {
    
    private let db = Firestore.firestore()
    
    /// Web parity: `BusinessProvider` / `fetchBusiness` — email invites, then owner, then active member.
    func resolveMembership(userId: String, email: String?, name: String? = nil) async throws -> MembershipResolution {
        await acceptPendingInvitesIfNeeded(userId: userId, email: email, name: name)

        let ownedSnapshot = try await db.collection("businesses")
            .whereField("ownerId", isEqualTo: userId)
            .limit(to: 3)
            .getDocuments()

        if let doc = ownedSnapshot.documents.first {
            return .active(businessId: doc.documentID)
        }

        let activeMembersSnapshot = try await db.collectionGroup("members")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .limit(to: 3)
            .getDocuments()

        if let doc = activeMembersSnapshot.documents.first,
           let businessId = doc.reference.parent.parent?.documentID {
            return .active(businessId: businessId)
        }

        let pendingMembersSnapshot = try await db.collectionGroup("members")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .limit(to: 1)
            .getDocuments()

        if let doc = pendingMembersSnapshot.documents.first,
           let businessId = doc.reference.parent.parent?.documentID {
            let businessName = try? await fetchBusinessName(businessId: businessId)
            return .pending(businessId: businessId, businessName: businessName)
        }

        return .none
    }

    func fetchCurrentBusinessId(userId: String, email: String?, name: String? = nil) async throws -> String? {
        switch try await resolveMembership(userId: userId, email: email, name: name) {
        case .active(let businessId):
            return businessId
        case .pending, .none:
            return nil
        }
    }

    func joinBusinessWithInviteCode(_ rawCode: String, user: User) async throws -> String {
        guard let code = FieldValidator.normalizedInviteCode(rawCode) else {
            throw BusinessJoinError.invalidInviteCode
        }

        let snapshot = try await db.collection("businesses")
            .whereField("inviteCode", isEqualTo: code)
            .limit(to: 1)
            .getDocuments()

        guard let businessDoc = snapshot.documents.first else {
            throw BusinessJoinError.businessNotFound
        }

        let businessId = businessDoc.documentID

        var memberData: [String: Any] = [
            "userId": user.id,
            "role": "technician",
            "status": "pending",
            "email": user.email,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
        ]

        if let memberName = user.name?.trimmingCharacters(in: .whitespacesAndNewlines), !memberName.isEmpty {
            memberData["name"] = memberName
        }

        try await db.collection("businesses")
            .document(businessId)
            .collection("members")
            .document(user.id)
            .setData(memberData, merge: true)

        return businessId
    }

    func cancelPendingMembership(userId: String) async throws {
        let snapshot = try await db.collectionGroup("members")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .limit(to: 1)
            .getDocuments()

        guard let memberDoc = snapshot.documents.first else { return }
        try await memberDoc.reference.delete()
    }

    func fetchVehicleCreateAccess(userId: String, email: String?, name: String? = nil) async throws -> VehicleCreateAccess? {
        guard let access = try await fetchBusinessAccess(userId: userId, email: email, name: name) else {
            return nil
        }
        return VehicleCreateAccess(businessId: access.businessId, role: access.role)
    }

    func fetchBusinessAccess(userId: String, email: String?, name: String? = nil) async throws -> BusinessAccess? {
        guard let businessId = try await fetchCurrentBusinessId(userId: userId, email: email, name: name) else {
            return nil
        }

        let businessSnapshot = try await db.collection("businesses").document(businessId).getDocument()
        let ownerId = businessSnapshot.data()?["ownerId"] as? String

        if ownerId == userId {
            return BusinessAccess(businessId: businessId, role: "owner")
        }

        let memberSnapshot = try await db.collection("businesses")
            .document(businessId)
            .collection("members")
            .document(userId)
            .getDocument()

        let role = memberSnapshot.data()?["role"] as? String
        return BusinessAccess(businessId: businessId, role: role)
    }

    func fetchBusinessName(businessId: String) async throws -> String? {
        let snapshot = try await db.collection("businesses").document(businessId).getDocument()
        return snapshot.data()?["name"] as? String
    }
    
    /// `collectionGroup("invites")` where `email` + `status == invited` → write member + delete invite (web `BusinessProvider`).
    private func acceptPendingInvitesIfNeeded(userId: String, email: String?, name: String?) async {
        guard let email = email, !email.isEmpty else { return }
        let emailLower = email.lowercased()
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let invitesSnapshot = try await db.collectionGroup("invites")
                .whereField("email", isEqualTo: emailLower)
                .whereField("status", isEqualTo: "invited")
                .limit(to: 5)
                .getDocuments()
            
            for invDoc in invitesSnapshot.documents {
                guard let businessId = invDoc.reference.parent.parent?.documentID else { continue }
                let data = invDoc.data()
                let role = (data["role"] as? String) ?? "viewer"
                
                let memberRef = db.collection("businesses").document(businessId).collection("members").document(userId)
                var memberData: [String: Any] = [
                    "userId": userId,
                    "role": role,
                    "status": "active",
                    "email": email,
                    "createdAt": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp(),
                ]

                if let trimmedName, !trimmedName.isEmpty {
                    memberData["name"] = trimmedName
                }

                try await memberRef.setData(memberData, merge: true)
                
                try await invDoc.reference.delete()
            }
        } catch {
            // Web: invite accept can fail; still resolve business afterward.
        }
    }
}
