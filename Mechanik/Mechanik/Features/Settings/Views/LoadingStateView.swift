//
//  LoadingStateView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//


import SwiftUI

struct LoadingStateView: View {

    var body: some View {

        VStack(spacing: 12) {

            ProgressView()

            Text("Ayarlar yükleniyor...")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}