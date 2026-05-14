import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = SettingsViewModel()
    @State private var hasLoaded = false
    @State private var isEditingBusinessName = false
    @State private var showInviteRefreshConfirm = false
    @State private var copied = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    
                    LoadingStateView()
                } else if viewModel.business == nil {
                    
                    CreateBusinessView(
                        businessName: $viewModel.newBusinessName,
                        isCreating: viewModel.isCreatingBusiness,
                        
                        onCreate: {
                            Task {
                                await viewModel.createBusiness(
                                    user: appState.currentUser
                                )
                            }
                        },
                        
                        onLogout: {
                            appState.logout()
                        }
                    )
                    
                } else {
                    settingsContent
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await viewModel.load(user: appState.currentUser)
            }
            .refreshable {
                await viewModel.load(user: appState.currentUser)
            }
            .alert(item: $viewModel.errorMessage) { message in
                Alert(
                    title: Text(message.title),
                    message: Text(message.message),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .alert(item: $viewModel.infoMessage) { message in
                Alert(
                    title: Text(message.title),
                    message: Text(message.message),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .alert(item: $viewModel.resetPasswordMessage) { message in
                Alert(
                    title: Text(message.title),
                    message: Text(message.message),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .confirmationDialog(
                "Davet kodunu yenile?",
                isPresented: $showInviteRefreshConfirm,
                titleVisibility: .visible
            ) {
                Button("Yenile", role: .destructive) {
                    Task { await viewModel.refreshInviteCode() }
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text(
                    "Mevcut kod geçersiz olur. Yeni kodu ekibinizle tekrar paylaşmanız gerekir."
                )
            }
        }
    }
    
    private var settingsContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                if viewModel.shouldShowVerificationBanner {
                    VerificationBanner {
                        Task {
                            await viewModel.resendVerificationEmail()
                        }
                    }
                }
                
                if let business = viewModel.business {
                    BusinessSectionView(
                        business: business,
                        isEditingBusinessName: $isEditingBusinessName,
                        businessNameDraft: $viewModel.businessNameDraft,
                        copied: $copied,
                        
                        isSavingName: viewModel.isSavingName,
                        canEditBusinessName: viewModel.canEditBusinessName,
                        canManageStaff: viewModel.canManageStaff,
                        isRefreshingInviteCode: viewModel.isRefreshingInviteCode,
                        
                        onSaveName: {
                            await viewModel.saveBusinessName()
                        },
                        
                        onRefreshInvite: {
                            showInviteRefreshConfirm = true
                        }
                    )
                }
                
                TeamSectionView(
                    viewModel: viewModel,
                    availableRolesForCurrentUser: availableRolesForCurrentUser
                )
                .environmentObject(appState)
                
                AccountSectionView(viewModel: viewModel)
                
                SignOutSectionView()
                    .environmentObject(appState)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
    
    private var availableRolesForCurrentUser: [String] {
        if viewModel.access?.role == "owner" {
            return ["manager", "technician", "viewer"]
        }
        return ["technician", "viewer"]
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
