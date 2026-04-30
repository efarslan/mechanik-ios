import SwiftUI

struct VehicleDetailView: View {
    
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = VehicleDetailViewModel()
    @State private var hasLoaded = false
    @State private var isNavigatingToNewJob = false
    @State private var shouldReloadAfterNewJob = false
    @State private var isPresentingEditSheet = false
    @State private var selectedJob: JobListItem?
    
    let vehicleId: String
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(screenBackground)
            } else if let errorMessage = viewModel.errorMessage, viewModel.vehicle == nil {
                FeedbackStateView(
                    icon: "exclamationmark.triangle",
                    title: "Araç Bulunamadı",
                    message: errorMessage
                )
                .background(screenBackground)
            } else {
                content
            }
        }
        .navigationTitle(viewModel.vehicle?.plate ?? "Araç Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await viewModel.load(user: appState.currentUser, vehicleId: vehicleId)
        }
        .navigationDestination(isPresented: $isNavigatingToNewJob) {
            NewJobView(vehicleId: vehicleId, didCreateJob: {
                shouldReloadAfterNewJob = true
            })
            .environmentObject(appState)
        }
        .onChange(of: isNavigatingToNewJob) { _, isActive in
            if !isActive, shouldReloadAfterNewJob {
                shouldReloadAfterNewJob = false
                Task { await viewModel.reload() }
            }
        }
        .sheet(isPresented: $isPresentingEditSheet) {
            NavigationStack {
                
                VehicleEditSheetView(
                    viewModel: viewModel,
                    isPresented: $isPresentingEditSheet,
                    screenBackground: screenBackgroundColor
                )
                    .navigationTitle("Araç Bilgilerini Düzenle")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Kapat") { isPresentingEditSheet = false }
                        }
                    }
            }
            .presentationDetents([.large])
        }
        .sheet(item: $selectedJob) { job in
            JobDetailSheetView(
                job: job,
                businessId: viewModel.access?.businessId ?? "",
                vehicleId: vehicleId
            ) { updatedJob in
                selectedJob = updatedJob
                Task { await viewModel.reload() }
            }
        }
    }
    
    private var screenBackgroundColor: Color {
        Color(red: 0.97, green: 0.97, blue: 0.96)
    }

    private var screenBackground: some View {
        screenBackgroundColor.ignoresSafeArea()
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if let errorMessage = viewModel.errorMessage, viewModel.vehicle != nil {
                    FeedbackStateView(
                        icon: "exclamationmark.circle",
                        title: "Bir sorun var",
                        message: errorMessage
                    )
                }
                heroCard
                jobsCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(screenBackground)
        .refreshable { await viewModel.reload() }
    }
    
    // MARK: - Hero Card
    
    private var heroCard: some View {
        guard let vehicle = viewModel.vehicle else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(spacing: 0) {
                // Accent bar
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.86, blue: 0.40),
                        Color(red: 0.95, green: 0.73, blue: 0.18)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 6)
                
                // Dark content area
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top, spacing: 16) {
                        VehicleBrandLogoView(
                            brandLogoURL: viewModel.brandLogoURL
                        )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(vehicle.plate)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contextMenu {
                                    Button {
                                        UIPasteboard.general.string = vehicle.plate
                                    } label: {
                                        Label("Plakayı Kopyala", systemImage: "doc.on.doc")
                                    }
                                }
                            
                            Text("\(vehicle.brand) \(vehicle.model)")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.70))
                            
                            HStack(spacing: 6) {
                                VehicleInfoBadgeView(title: "\(vehicle.year)")
                                if let engineSize = vehicle.engineSize, !engineSize.isEmpty {
                                    VehicleInfoBadgeView(title: engineSize)
                                }
                                VehicleInfoBadgeView(title: VehicleFuelType(storageValue: vehicle.fuelType).title)
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.canEditVehicle {
                            Button {
                                viewModel.populateEditFields()
                                isPresentingEditSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        VehicleDetailRow(
                            icon: "person.fill",
                            title: "Araç Sahibi",
                            value: vehicle.ownerName
                        )
                        
                        if let ownerPhone = vehicle.ownerPhone, !ownerPhone.isEmpty {
                            Button {
                                let cleaned = ownerPhone.filter { $0.isNumber || $0 == "+" }
                                if let url = URL(string: "tel:\(cleaned)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                VehicleDetailRow(
                                    icon: "phone.fill",
                                    title: "Telefon",
                                    value: ownerPhone,
                                    valueColor: Color(red: 0.98, green: 0.86, blue: 0.40)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if let chassisNo = vehicle.chassisNo, !chassisNo.isEmpty {
                            VehicleDetailRow(
                                icon: "barcode.viewfinder",
                                title: "Şasi No",
                                value: chassisNo
                            )
                        }
                        
                        if let notes = vehicle.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.footnote)
                                .foregroundStyle(Color.white.opacity(0.70))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.13, blue: 0.11),
                            Color(red: 0.22, green: 0.17, blue: 0.11)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Stats bar — tutarlı renk sistemi
                HStack(spacing: 0) {
                    VehicleStatsItem(
                        title: "Toplam",
                        value: "\(viewModel.jobStats.total)",
                        valueColor: Color(red: 0.14, green: 0.13, blue: 0.11)
                    )
                    Divider().frame(height: 28)
                    VehicleStatsItem(
                        title: "Aktif",
                        value: "\(viewModel.jobStats.active)",
                        valueColor: .green
                    )
                    Divider().frame(height: 28)
                    VehicleStatsItem(
                        title: "Tamamlanan",
                        value: "\(viewModel.jobStats.completed)",
                        valueColor: Color(red: 0.98, green: 0.76, blue: 0.20)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(.white)
            }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - Jobs Card
    
    private var jobsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Servis Geçmişi")
                        .font(.headline)
                    Text("\(viewModel.filteredJobs.count) İşlem")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if viewModel.canCreateJob && appState.currentUser?.emailVerified == true {
                    Button {
                        isNavigatingToNewJob = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.caption.weight(.bold))
                            Text("Yeni İşlem")
                                .font(.subheadline.weight(.bold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color(red: 0.94, green: 0.75, blue: 0.20))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Search — tam genişlik
            searchField
            
            // Sort + Segment yan yana
            HStack(spacing: 10) {
                Picker("Durum", selection: $viewModel.statusFilter) {
                    ForEach(VehicleDetailViewModel.JobStatusFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                
                Button {
                    viewModel.sortDirection = viewModel.sortDirection == .newestFirst ? .oldestFirst : .newestFirst
                } label: {
                    Image(
                        systemName: viewModel.sortDirection == .newestFirst
                        ? "arrow.down.to.line"
                        : "arrow.up.to.line"
                    )
                    .font(.subheadline.weight(.bold))
                    .frame(width: 40, height: 34)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            
            // List or empty
            if viewModel.filteredJobs.isEmpty {
                emptyJobsView
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.filteredJobs) { job in
                        Button {
                            selectedJob = job
                        } label: {
                            jobRow(job)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private var emptyJobsView: some View {
        let isEmpty = viewModel.jobs.isEmpty
        return VStack(spacing: 10) {
            Image(systemName: isEmpty ? "wrench.and.screwdriver" : "magnifyingglass")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.35))
            
            Text(isEmpty ? "Henüz işlem yok" : "Sonuç bulunamadı")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(isEmpty
                 ? "Bu araç icin ilk servis kaydını oluşturun."
                 : "Arama veya filtre kriterlerini değiştirin."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.subheadline)
            
            TextField("İşlemlerde Ara...", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - Job Row
    
    private func jobRow(_ job: JobListItem) -> some View {
        HStack(spacing: 12) {
            // Status indicator
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(job.status.color)
                .frame(width: 4, height: 44)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(job.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(job.totalAmount.formattedCurrency)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.85))
                }
                
                HStack(spacing: 6) {
                    Text(job.status.title)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(job.status.color.opacity(0.12))
                        .foregroundStyle(job.status.color)
                        .clipShape(Capsule())
                    
                    if let createdAt = job.createdAt {
                        Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let mileage = job.mileage, mileage > 0 {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("\(mileage.formatted(.number.locale(Locale(identifier: "tr_TR")))) km")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.gray.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    // MARK: - Preview
    #Preview {
        VehicleListView()
            .environmentObject(AppState())
    }
}
