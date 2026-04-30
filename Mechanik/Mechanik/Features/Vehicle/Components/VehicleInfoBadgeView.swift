//
//  VehicleInfoBadgeView.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct VehicleInfoBadgeView: View {

    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.10))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
