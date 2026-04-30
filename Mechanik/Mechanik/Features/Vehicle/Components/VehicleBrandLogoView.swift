//
//  File.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct VehicleBrandLogoView: View {

    let brandLogoURL: String?

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(Color.white.opacity(0.08))

            if let brandLogoURL,
               let url = URL(string: brandLogoURL) {

                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(12)

                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }

            } else {

                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundStyle(
                        Color.white.opacity(0.5)
                    )
            }
        }
        .frame(width: 68, height: 68)
    }
}
