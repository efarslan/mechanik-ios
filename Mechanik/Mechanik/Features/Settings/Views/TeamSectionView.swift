//
//  TeamSectionView.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct TeamSectionView: View {

    @EnvironmentObject private var appState: AppState

    @ObservedObject var viewModel: SettingsViewModel

    let availableRolesForCurrentUser: [String]

    var body: some View {

        SettingsCard(
            title: "Çalışanlar ve Roller",
            icon: "person.crop.rectangle.stack.fill"
        ) {

            if !viewModel.canManageStaff {

                Text("Çalışan yönetimi için yetkiniz bulunmuyor.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

            } else if !(appState.currentUser?.emailVerified ?? false) {

                Text(
                    "E-posta doğrulaması tamamlanmadan çalışan yönetimi kısıtlıdır."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

            } else {

                if !viewModel.pendingMembers.isEmpty {

                    VStack(alignment: .leading, spacing: 10) {

                        Text("Bekleyen Başvurular")
                            .font(.subheadline.weight(.bold))

                        ForEach(viewModel.pendingMembers) { member in

                            MemberPending(
                                member: member,

                                onReject: {

                                    guard let actorId = appState.currentUser?.id else {
                                        return
                                    }

                                    Task {
                                        await viewModel.rejectMember(
                                            member,
                                            actorId: actorId
                                        )
                                    }
                                },

                                onApprove: {

                                    guard let actorId = appState.currentUser?.id else {
                                        return
                                    }

                                    Task {
                                        await viewModel.approveMember(
                                            member,
                                            actorId: actorId
                                        )
                                    }
                                }
                            )
                        }
                    }
                    .padding(.bottom, 6)
                }

                VStack(alignment: .leading, spacing: 10) {

                    Text("Aktif Çalışanlar")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)

                    if viewModel.activeMembers.isEmpty {

                        Text("Henüz aktif çalışan yok.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(viewModel.activeMembers) { member in

                            MemberActive(
                                member: member,

                                selectedRole:
                                    viewModel.pendingRoles[member.id]
                                    ?? member.role,

                                availableRoles: availableRolesForCurrentUser,

                                onRoleChange: { newRole in

                                    viewModel.updatePendingRole(
                                        memberId: member.id,
                                        role: newRole,
                                        currentRole: member.role
                                    )
                                },

                                onRemove: {

                                    guard let actorId = appState.currentUser?.id else {
                                        return
                                    }

                                    Task {
                                        await viewModel.removeMember(
                                            member,
                                            actorId: actorId
                                        )
                                    }
                                }
                            )
                        }
                    }
                }

                if viewModel.hasPendingRoleChanges {

                    HStack {

                        Button("Geri Al") {
                            viewModel.discardPendingRoles()
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button(
                            viewModel.isSavingRoles
                            ? "Kaydediliyor..."
                            : "Rol Değişikliklerini Kaydet"
                        ) {

                            guard let actorId = appState.currentUser?.id else {
                                return
                            }

                            Task {
                                await viewModel.saveRoleChanges(
                                    actorId: actorId
                                )
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.black.opacity(0.85))
                        .disabled(viewModel.isSavingRoles)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}
