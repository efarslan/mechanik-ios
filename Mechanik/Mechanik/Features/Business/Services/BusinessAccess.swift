//
//  BusinessAccess.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import Foundation

enum MembershipResolution: Equatable {
    case none
    case pending(businessId: String, businessName: String?)
    case active(businessId: String)
}

enum BusinessJoinError: LocalizedError {
    case invalidInviteCode
    case businessNotFound

    var errorDescription: String? {
        switch self {
        case .invalidInviteCode:
            return "Davet kodu 8 karakter olmalıdır (XXXX-XXXX)."
        case .businessNotFound:
            return "Geçersiz davet kodu."
        }
    }
}

struct BusinessAccess {
    let businessId: String
    let role: String?

    var canCreateVehicle: Bool {
        role == "owner" || role == "manager"
    }

    var canCreateJob: Bool {
        role == "owner" || role == "manager" || role == "technician"
    }
}