//
//  heroCardView.swift
//  Mechanik
//
//  Created by efe arslan on 7.05.2026.
//

import SwiftUI

struct HeroCardView: View {
    let businessName: String
    let canCreateVehicle: Bool
    let onVehiclesTap: () -> Void
    let onCreateVehicleTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(businessName.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(Color.white.opacity(0.72))

                    Text("Mobil Kontrol Merkezi")
                        .font(
                            .system(
                                size: 28,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)

                    Text(
                        "Aktif işleri, kritik uyarıları ve son 14 günün ritmini tek ekranda takip edin."
                    )
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.74))
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Button {
                    onVehiclesTap()
                } label: {
                    Label("Araçlara Git", systemImage: "car.fill")
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Color(
                                red: 0.94,
                                green: 0.75,
                                blue: 0.20
                            )
                        )
                        .foregroundStyle(Color.black.opacity(0.88))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)

                if canCreateVehicle {
                    Button {
                        onCreateVehicleTap()
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.bold))
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.12))
                            .foregroundStyle(.white)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 14,
                                    style: .continuous
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.12, blue: 0.10),
                    Color(red: 0.24, green: 0.18, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 120, height: 120)
                .offset(x: 34, y: -40)
        }
    }
}
