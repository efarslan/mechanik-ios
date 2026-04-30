import SwiftUI

struct VehicleListView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = VehicleListViewModel()
    @State private var hasLoaded = false
    @State private var isNavigatingToNewVehicle = false
    @State private var shouldReloadAfterDismiss = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage {
                    feedbackState(
                        icon: "exclamationmark.triangle",
                        title: "Araçlar Yüklenemedi",
                        message: errorMessage
                    )
                } else {
                    vehicleContent
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            .navigationTitle("Araçlar")
            .navigationBarTitleDisplayMode(.large)
            .task {
                guard !hasLoaded, let user = appState.currentUser else { return }
                hasLoaded = true
                await viewModel.load(userId: user.id, email: user.email)
            }
            .refreshable {
                await reloadVehicles()
            }
            .navigationDestination(isPresented: $isNavigatingToNewVehicle) {
                NewVehicleView(didCreateVehicle: {
                    shouldReloadAfterDismiss = true
                })
                    .environmentObject(appState)
            }
            .onChange(of: isNavigatingToNewVehicle) { _, isActive in
                if !isActive {
                    handleNavigationDismiss()
                }
            }
        }
    }

    private var vehicleContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                headerCard

                if !viewModel.vehicles.isEmpty {
                    searchField
                }

                if viewModel.vehicles.isEmpty {
                    feedbackState(
                        icon: "car.side",
                        title: "Henuz Araç Yok",
                        message: "Servis geçmişi tutmak için ilk aracı ekleyin."
                    )
                } else if viewModel.filteredVehicles.isEmpty {
                    feedbackState(
                        icon: "magnifyingglass",
                        title: "Araç bulunamadı",
                        message: "\"\(viewModel.searchText)\" için sonuç yok."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredVehicles) { vehicle in
                            NavigationLink {
                                VehicleDetailView(vehicleId: vehicle.id)
                                    .environmentObject(appState)
                            } label: {
                                vehicleRow(vehicle)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private var headerCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Araclar")
                    .font(.title3.weight(.bold))

                Text(viewModel.vehicles.isEmpty ? "Henüz araç eklenmedi" : "\(viewModel.vehicles.count) Araç Kayıtlı")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                isNavigatingToNewVehicle = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Araç Ekle")
                }
                .font(.subheadline.weight(.bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(red: 0.94, green: 0.75, blue: 0.20))
                .foregroundStyle(Color.black.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Plaka, Marka, Model veya Araç Sahibi ara...", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func vehicleRow(_ vehicle: Vehicle) -> some View {
        HStack(spacing: 14) {
            logoView(for: vehicle)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(vehicle.plate)
                        .font(.system(.subheadline, design: .monospaced).weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.86))

                    Text("\(vehicle.brand) \(vehicle.model)")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Text(vehicle.ownerName)
                    Text("•")
                    Text(String(vehicle.year))

                    if !vehicle.fuelType.isEmpty {
                        Text("•")
                        Text(VehicleFuelType(storageValue: vehicle.fuelType).title)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func logoView(for vehicle: Vehicle) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.97, green: 0.97, blue: 0.96))

            if let logoURL = viewModel.brandLogos[vehicle.brand], let url = URL(string: logoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } placeholder: {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            } else {
                Text(String(vehicle.brand.prefix(2)).uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 50, height: 50)
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Yükleniyor...")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func feedbackState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.5))

            Text(title)
                .font(.headline)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if icon != "magnifyingglass" {
                Button("Araç Ekle") {
                    isNavigatingToNewVehicle = true
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.94, green: 0.75, blue: 0.20))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 24)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func handleNavigationDismiss() {
        guard shouldReloadAfterDismiss else { return }
        shouldReloadAfterDismiss = false

        Task {
            await reloadVehicles()
        }
    }

    private func reloadVehicles() async {
        guard let user = appState.currentUser else { return }
        await viewModel.load(userId: user.id, email: user.email)
    }
}

#Preview {
    VehicleListView()
        .environmentObject(AppState())
}
