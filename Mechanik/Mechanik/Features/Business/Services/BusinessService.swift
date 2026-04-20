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
    
    /// Web parity: `BusinessProvider` / `fetchBusiness` — invites first, then owner, then member.
    func fetchCurrentBusinessId(userId: String, email: String?) async throws -> String? {
        await acceptPendingInvitesIfNeeded(userId: userId, email: email)
        
        // 1) Owner
        let ownedSnapshot = try await db.collection("businesses")
            .whereField("ownerId", isEqualTo: userId)
            .limit(to: 3)
            .getDocuments()
        
        if let doc = ownedSnapshot.documents.first {
            return doc.documentID
        }
        
        // 2) Active member
        let membersSnapshot = try await db.collectionGroup("members")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .limit(to: 3)
            .getDocuments()
        
        if let doc = membersSnapshot.documents.first,
           let businessRef = doc.reference.parent.parent {
            return businessRef.documentID
        }
        
        return nil
    }
    
    /// `collectionGroup("invites")` where `email` + `status == invited` → write member + delete invite (web `BusinessProvider`).
    private func acceptPendingInvitesIfNeeded(userId: String, email: String?) async {
        guard let email = email, !email.isEmpty else { return }
        let emailLower = email.lowercased()
        
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
                try await memberRef.setData([
                    "userId": userId,
                    "role": role,
                    "status": "active",
                    "email": email,
                    "createdAt": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp(),
                ], merge: true)
                
                try await invDoc.reference.delete()
            }
        } catch {
            // Web: invite accept can fail; still resolve business afterward.
        }
    }
}
