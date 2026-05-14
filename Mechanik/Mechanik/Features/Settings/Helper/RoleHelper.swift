//
//  RoleHelper.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import Foundation

func roleLabel(_ role: String) -> String {

    switch role {

    case "owner":
        return "İşletme Sahibi"

    case "manager":
        return "Yönetici"

    case "technician":
        return "Teknisyen"

    case "viewer":
        return "Görüntüleyici"

    default:
        return role.capitalized
    }
}
