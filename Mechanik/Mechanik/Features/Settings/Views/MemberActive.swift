//
//  MemberActive.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//


import SwiftUI

struct MemberActive: View {

    let member: TeamMember

    let selectedRole: String
    let availableRoles: [String]

    let onRoleChange: (String) -> Void
    let onRemove: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 6) {

                MemberAvatar(member: member)

                VStack(alignment: .leading) {

                    Text(member.displayName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    if let email = member.email {

                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text(roleLabel(member.role))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 6,
                            style: .continuous
                        )
                        .fill(
                            roleColor(member.role)
                                .opacity(0.75)
                        )
                    )
            }

            if member.role == "owner" {

                Text("Owner rolü değiştirilemez.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            } else {

                Picker(
                    "Rol",
                    selection: Binding(
                        get: {
                            selectedRole
                        },
                        set: { newValue in
                            onRoleChange(newValue)
                        }
                    )
                ) {

                    ForEach(availableRoles, id: \.self) { role in

                        Text(roleLabel(role))
                            .tag(role)
                    }
                }
                .pickerStyle(.segmented)

                Button(
                    "Çalışanı Kaldır",
                    role: .destructive
                ) {
                    onRemove()
                }
                .font(.caption.weight(.semibold))
            }
        }
        .padding(12)
        .background(.white)
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .stroke(
                Color.gray.opacity(0.18),
                lineWidth: 1
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
    }
}
