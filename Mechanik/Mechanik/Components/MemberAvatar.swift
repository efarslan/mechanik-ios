//
//  MemberAvatar.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct MemberAvatar: View {

    let member: TeamMember

    var body: some View {

        Text(initials)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 38, height: 38)
            .background(
                LinearGradient(
                    colors: [
                        roleColor(member.role),
                        roleColor(member.role).opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private var initials: String {

        let source =
            member.name?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty == false
            ? member.name ?? ""
            : member.displayName

        let words = source
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)

        guard let firstWord = words.first else {
            return "?"
        }

        let lastWord =
            words.count > 1
            ? words.last ?? firstWord
            : firstWord

        let initials =
            "\(firstWord.prefix(1))\(lastWord.prefix(1))"

        return initials.uppercased(
            with: Locale(identifier: "tr_TR")
        )
    }
}
