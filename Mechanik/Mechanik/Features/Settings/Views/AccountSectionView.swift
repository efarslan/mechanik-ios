//
//  AccountSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct AccountSectionView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        SettingsCard(title: "Hesap", icon: "person.crop.circle.fill") {

            LabeledRow(
                label: "E-posta",
                value: appState.currentUser?.email ?? "—"
            )

            Divider()

            CopyableTruncatedTextRow(
                label: "Kullanıcı ID",
                value: appState.currentUser?.id ?? "—"
            )

            SettingsActionButton(
                title: "Şifremi Unuttum",
                bgColor: .white,
                borderColor: .black
            ) {
                guard let email = appState.currentUser?.email else { return }

                Task {
                    await viewModel.sendPasswordReset(email: email)
                }
            }
            .disabled(viewModel.isSendingPasswordReset)
            .overlay {
                if viewModel.isSendingPasswordReset {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.6))
                        ProgressView()
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}
