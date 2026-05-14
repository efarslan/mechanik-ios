//
//  ColorHelper.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import Foundation
import SwiftUI

func roleColor(_ role: String) -> Color {

    switch role {

    case "owner":
        return .appYellow

    case "manager":
        return .blue

    case "technician":
        return .green

    case "viewer":
        return .gray

    default:
        return .gray
    }
}
