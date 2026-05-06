//
//  AlertItem.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import Foundation

struct AlertItem: Identifiable {
    let id: String
    let kind: AlertKind
    let job: JobListItem
    let vehicle: Vehicle?
    let subtitle: String
}
