//
//  DashboardCard.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct DashboardCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(18)
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 10,
            x: 0,
            y: 3
        )
    }
}
