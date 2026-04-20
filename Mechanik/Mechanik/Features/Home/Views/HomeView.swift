import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // HEADER
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mechanik")
                        .font(.largeTitle)
                        .bold()
                    
                    if let user = appState.currentUser {
                        Text("User: \(user.id)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // QUICK ACTIONS
                VStack(spacing: 12) {
                    
                    NavigationLink {
                        VehicleListView()
                            .environmentObject(appState)
                    } label: {
                        HomeCard(
                            title: "Vehicles",
                            subtitle: "Manage all vehicles",
                            systemImage: "car.fill"
                        )
                    }
                    
                    HomeCard(
                        title: "Services",
                        subtitle: "Coming soon",
                        systemImage: "wrench.and.screwdriver"
                    )
                    .opacity(0.5)
                    
                    HomeCard(
                        title: "Reports",
                        subtitle: "Coming soon",
                        systemImage: "chart.bar"
                    )
                    .opacity(0.5)
                }
                
                Spacer()
                
                // LOGOUT
                Button {
                    appState.logout()
                } label: {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    let appState = AppState()
    HomeView()
        .environmentObject(appState)
}
