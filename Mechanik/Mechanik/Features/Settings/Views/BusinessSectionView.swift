//
//  BusinessSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct BusinessSectionView: View {

    let business: SettingsBusiness

    @Binding var isEditingBusinessName: Bool
    @Binding var businessNameDraft: String
    @Binding var copied: Bool

    var businessNameError: String? = nil
    let isSavingName: Bool
    let canEditBusinessName: Bool
    let canManageStaff: Bool
    let isRefreshingInviteCode: Bool

    let onSaveName: () async -> Void
    let onRefreshInvite: () -> Void

    var body: some View {

        SettingsCard(title: "İşletme", icon: "storefront") {

            // MARK: NAME EDIT
            if isEditingBusinessName {

                VStack(alignment: .leading, spacing: 6) {
                    TextField("İşletme adı", text: $businessNameDraft)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(Color.gray.opacity(0.08))
                        .invalidFieldBorder(isInvalid: businessNameError != nil, cornerRadius: 12)
                        .id(FormFieldAnchor.businessName.rawValue)

                    FormErrorText(message: businessNameError)
                }

                HStack {
                    Button("İptal") {
                        isEditingBusinessName = false
                        businessNameDraft = business.name
                    }

                    Spacer()

                    Button(isSavingName ? "Kaydediliyor..." : "Kaydet") {
                        Task {
                            await onSaveName()
                            isEditingBusinessName = false
                        }
                    }
                    .disabled(isSavingName)
                }

            } else {

                // MARK: BASIC INFO
                HStack {
                    LabeledRow(label: "İşletme adı", value: business.name)

                    if canEditBusinessName {
                        Button {
                            isEditingBusinessName = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()

                CopyableTruncatedTextRow(
                    label: "İşletme ID",
                    value: business.id
                )

                Divider()

                // MARK: INVITE CODE
                if canManageStaff {

                    HStack {
                        Text("Davet Kodu")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            UIPasteboard.general.string = business.inviteCode

                            withAnimation { copied = true }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation { copied = false }
                            }

                        } label: {
                            Text(copied ? "Kopyalandı" : business.inviteCode)
                                .font(.system(.headline, design: .monospaced))
                                .frame(minWidth: 120)
                                .padding(.vertical, 10)
                                .background(Color.appYellow.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()

                // MARK: REFRESH
                if canManageStaff {
                    SettingsActionButton(
                        title: "Davet Kodunu Yenile",
                        bgColor: .white,
                        txtColor: .red,
                        borderColor: .red
                    ) {
                        onRefreshInvite()
                    }
                    .disabled(isRefreshingInviteCode)
                }
            }
        }
    }
}
