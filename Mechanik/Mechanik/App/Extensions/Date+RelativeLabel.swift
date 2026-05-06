//
//  Date+RelativeLabel.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//


import Foundation

extension Date {
    var relativeLabel: String {
        let diff = Date().timeIntervalSince(self)

        if diff < 60 {
            return "şimdi"
        }

        if diff < 3600 {
            return "\(Int(diff / 60)) dk önce"
        }

        if diff < 86_400 {
            return "\(Int(diff / 3600)) sa önce"
        }

        return "\(Int(diff / 86_400)) g önce"
    }
}