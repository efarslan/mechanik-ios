//
//  SignOutSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//


//
//  SignOutSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct SignOutSectionView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {

        SettingsActionButton(
            title: "Çıkış Yap",
            bgColor: .red,
            txtColor: .white
        ) {
            appState.logout()
        }
    }
}

#Preview {
    SignOutSectionView()
        .environmentObject(AppState())
}