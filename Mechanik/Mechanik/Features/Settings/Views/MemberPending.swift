//
//  MemberPending.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct MemberPending: View {

    let member: TeamMember
    let onReject: () -> Void
    let onApprove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            MemberAvatar(member: member)

            VStack(alignment: .leading, spacing: 6) {

                Text(member.displayName)
                    .font(.subheadline.weight(.semibold))

                Text(member.id)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)

                HStack {

                    Button("Reddet", role: .destructive) {
                        onReject()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Onayla") {
                        onApprove()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
