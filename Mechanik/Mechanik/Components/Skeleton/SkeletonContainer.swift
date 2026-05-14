import SwiftUI

struct SkeletonContainer<Content: View>: View {
    var background: Color = Color(red: 0.97, green: 0.97, blue: 0.96)
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
        }
        .background(background.ignoresSafeArea())
    }
}

struct AppLaunchSkeleton: View {
    var body: some View {
        VStack(spacing: 18) {
            SkeletonView(width: 92, height: 92, cornerRadius: 24)
            SkeletonView(width: 160, height: 22, cornerRadius: 8)
            SkeletonView(width: 220, height: 14, cornerRadius: 7, opacity: 0.75)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.97, green: 0.97, blue: 0.96).ignoresSafeArea())
    }
}

struct ButtonLoadingSkeleton: View {
    var body: some View {
        SkeletonView(width: 18, height: 18, cornerRadius: 9, opacity: 0.7)
    }
}

struct HomeSkeletonView: View {
    var body: some View {
        SkeletonContainer {
            VStack(alignment: .leading, spacing: 18) {
                SkeletonView(width: 150, height: 38, cornerRadius: 10)
                HomeHeroSkeleton()
                HomeAlertsSkeleton()
                HomeRecentJobsSkeleton()
                HomeKPISkeleton()
                HomeChartSkeleton()
            }
        }
    }
}

struct HomeHeroSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SkeletonView(width: 110, height: 12, cornerRadius: 6, opacity: 0.65)
            SkeletonView(width: 230, height: 30, cornerRadius: 9, opacity: 0.75)
            SkeletonView(height: 36, cornerRadius: 8, opacity: 0.55)
            HStack(spacing: 10) {
                SkeletonView(height: 48, cornerRadius: 14, opacity: 0.75)
                SkeletonView(width: 48, height: 48, cornerRadius: 14, opacity: 0.55)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.13, green: 0.12, blue: 0.10), Color(red: 0.24, green: 0.18, blue: 0.11)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct HomeKPISkeleton: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 10) {
                        SkeletonView(width: 38, height: 38, cornerRadius: 12)
                        SkeletonView(width: 82, height: 10, cornerRadius: 5)
                        SkeletonView(width: 68, height: 32, cornerRadius: 8)
                        SkeletonView(width: 105, height: 12, cornerRadius: 6, opacity: 0.7)
                    }
                    .padding(16)
                    .frame(width: 185, height: 170, alignment: .topLeading)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

struct HomeAlertsSkeleton: View {
    var body: some View {
        DashboardSkeletonCard(spacing: 14) {
            HStack {
                SkeletonView(width: 150, height: 20, cornerRadius: 8)
                Spacer()
                SkeletonView(width: 30, height: 22, cornerRadius: 11)
            }
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: 12) {
                    CircleSkeletonView(size: 38)
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonView(height: 14, cornerRadius: 7)
                        SkeletonView(width: 80, height: 11, cornerRadius: 6, opacity: 0.8)
                        SkeletonView(width: 190, height: 11, cornerRadius: 6, opacity: 0.65)
                    }
                    Spacer()
                    SkeletonView(width: 10, height: 18, cornerRadius: 5)
                }
            }
        }
    }
}

struct HomeRecentJobsSkeleton: View {
    var body: some View {
        DashboardSkeletonCard(spacing: 14) {
            HStack {
                SkeletonView(width: 80, height: 20, cornerRadius: 8)
                Spacer()
                SkeletonView(width: 54, height: 12, cornerRadius: 6, opacity: 0.7)
            }
            ForEach(0..<3, id: \.self) { _ in
                JobListSkeletonRow()
            }
        }
    }
}

struct HomeChartSkeleton: View {
    var body: some View {
        DashboardSkeletonCard(spacing: 16) {
            SkeletonView(width: 92, height: 20, cornerRadius: 8)
            SkeletonView(height: 34, cornerRadius: 8)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach([82, 118, 66, 142, 104, 158, 90, 130, 74, 150], id: \.self) { height in
                    SkeletonView(height: CGFloat(height), cornerRadius: 5)
                }
            }
            .frame(height: 190, alignment: .bottom)
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonView(width: 132, height: 38, cornerRadius: 14)
                }
            }
        }
    }
}

struct SettingsSkeletonView: View {
    var body: some View {
        SkeletonContainer {
            VStack(spacing: 32) {
                SettingsBusinessSectionSkeleton()
                SettingsTeamSectionSkeleton()
                SettingsAccountSectionSkeleton()
            }
        }
    }
}

struct SettingsBusinessSectionSkeleton: View {
    var body: some View {
        SettingsSkeletonCard(titleWidth: 78, iconSize: 26) {
            SettingRowSkeleton(valueWidth: 150)
            Divider()
            SettingRowSkeleton(valueWidth: 190)
            Divider()
            HStack {
                SkeletonView(width: 72, height: 12, cornerRadius: 6)
                Spacer()
                SkeletonView(width: 120, height: 38, cornerRadius: 10)
            }
            Divider()
            SkeletonView(height: 44, cornerRadius: 14)
        }
    }
}

struct SettingsTeamSectionSkeleton: View {
    var body: some View {
        SettingsSkeletonCard(titleWidth: 170, iconSize: 26) {
            SkeletonView(width: 128, height: 16, cornerRadius: 8)
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    CircleSkeletonView(size: 34)
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonView(width: 140, height: 14, cornerRadius: 7)
                        SkeletonView(width: 190, height: 11, cornerRadius: 6, opacity: 0.7)
                    }
                    Spacer()
                    SkeletonView(width: 92, height: 34, cornerRadius: 10)
                }
            }
        }
    }
}

struct SettingsAccountSectionSkeleton: View {
    var body: some View {
        SettingsSkeletonCard(titleWidth: 70, iconSize: 26) {
            SettingRowSkeleton(valueWidth: 180)
            Divider()
            SettingRowSkeleton(valueWidth: 210)
            SkeletonView(height: 44, cornerRadius: 14)
                .padding(.top, 8)
        }
    }
}

struct VehicleListSkeletonView: View {
    var body: some View {
        SkeletonContainer {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        SkeletonView(width: 78, height: 20, cornerRadius: 8)
                        SkeletonView(width: 120, height: 12, cornerRadius: 6, opacity: 0.7)
                    }
                    Spacer()
                    SkeletonView(width: 108, height: 40, cornerRadius: 14)
                }
                .padding(18)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                SkeletonView(height: 46, cornerRadius: 18)
                LazyVStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        VehicleListSkeletonRow()
                    }
                }
            }
        }
    }
}

struct VehicleListSkeletonRow: View {
    var body: some View {
        HStack(spacing: 14) {
            SkeletonView(width: 50, height: 50, cornerRadius: 14)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    SkeletonView(width: 78, height: 15, cornerRadius: 7)
                    SkeletonView(width: 126, height: 12, cornerRadius: 6, opacity: 0.7)
                }
                SkeletonView(width: 190, height: 11, cornerRadius: 6, opacity: 0.65)
            }
            Spacer()
            SkeletonView(width: 10, height: 18, cornerRadius: 5, opacity: 0.6)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct VehicleDetailSkeletonView: View {
    var body: some View {
        SkeletonContainer {
            VStack(spacing: 16) {
                VehicleDetailHeaderSkeleton()
                VehicleDetailJobsSkeleton()
            }
        }
    }
}

struct VehicleDetailHeaderSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            SkeletonView(height: 6, cornerRadius: 0, opacity: 0.5)
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    SkeletonView(width: 68, height: 68, cornerRadius: 18, opacity: 0.75)
                    VStack(alignment: .leading, spacing: 8) {
                        SkeletonView(width: 126, height: 28, cornerRadius: 8, opacity: 0.75)
                        SkeletonView(width: 160, height: 14, cornerRadius: 7, opacity: 0.6)
                        HStack(spacing: 6) {
                            SkeletonView(width: 54, height: 24, cornerRadius: 12, opacity: 0.55)
                            SkeletonView(width: 72, height: 24, cornerRadius: 12, opacity: 0.55)
                            SkeletonView(width: 64, height: 24, cornerRadius: 12, opacity: 0.55)
                        }
                    }
                    Spacer()
                    SkeletonView(width: 36, height: 36, cornerRadius: 12, opacity: 0.55)
                }
                VehicleDetailInfoSkeleton()
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.14, green: 0.13, blue: 0.11), Color(red: 0.22, green: 0.17, blue: 0.11)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    VStack(spacing: 6) {
                        SkeletonView(width: 66, height: 10, cornerRadius: 5)
                        SkeletonView(width: 28, height: 20, cornerRadius: 7)
                    }
                    .frame(maxWidth: .infinity)
                    if index < 2 { Divider().frame(height: 28) }
                }
            }
            .padding(.vertical, 12)
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

struct VehicleDetailInfoSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                HStack(spacing: 10) {
                    CircleSkeletonView(size: 28, opacity: 0.55)
                    VStack(alignment: .leading, spacing: 5) {
                        SkeletonView(width: 86, height: 10, cornerRadius: 5, opacity: 0.5)
                        SkeletonView(width: index == 2 ? 210 : 150, height: 14, cornerRadius: 7, opacity: 0.65)
                    }
                }
            }
        }
    }
}

struct VehicleDetailJobsSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    SkeletonView(width: 120, height: 18, cornerRadius: 8)
                    SkeletonView(width: 54, height: 11, cornerRadius: 6, opacity: 0.65)
                }
                Spacer()
                SkeletonView(width: 112, height: 36, cornerRadius: 12)
            }
            SkeletonView(height: 42, cornerRadius: 14)
            HStack(spacing: 10) {
                SkeletonView(height: 34, cornerRadius: 8)
                SkeletonView(width: 40, height: 34, cornerRadius: 10)
            }
            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { _ in
                    JobListSkeletonRow()
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct JobListSkeletonRow: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(width: 4, height: 44, cornerRadius: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    SkeletonView(width: 160, height: 14, cornerRadius: 7)
                    Spacer()
                    SkeletonView(width: 70, height: 14, cornerRadius: 7)
                }
                HStack(spacing: 6) {
                    SkeletonView(width: 58, height: 20, cornerRadius: 10, opacity: 0.7)
                    SkeletonView(width: 72, height: 11, cornerRadius: 6, opacity: 0.6)
                    Spacer()
                    SkeletonView(width: 10, height: 16, cornerRadius: 5, opacity: 0.6)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct JobDetailSkeletonView: View {
    var body: some View {
        SkeletonContainer(background: Color(.systemBackground)) {
            VStack(alignment: .leading, spacing: 20) {
                JobDetailInfoSkeleton()
                JobDetailTimelineSkeleton()
                JobDetailHeaderSkeleton()
            }
        }
    }
}

struct JobDetailHeaderSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(width: 150, height: 24, cornerRadius: 8)
            SkeletonView(height: 56, cornerRadius: 16)
            HStack(spacing: 10) {
                SkeletonView(height: 44, cornerRadius: 14)
                SkeletonView(height: 44, cornerRadius: 14)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct JobDetailInfoSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SkeletonView(width: 180, height: 24, cornerRadius: 8)
            SkeletonView(width: 110, height: 12, cornerRadius: 6, opacity: 0.7)
            HStack(spacing: 12) {
                SkeletonView(height: 54, cornerRadius: 14)
                SkeletonView(height: 54, cornerRadius: 14)
            }
            SkeletonView(height: 84, cornerRadius: 16)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct JobDetailTimelineSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(width: 132, height: 18, cornerRadius: 8)
            ForEach(0..<3, id: \.self) { _ in
                JobListSkeletonRow()
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct NewVehicleSkeletonView: View {
    var body: some View {
        SkeletonContainer {
            VStack(spacing: 16) {
                NewJobSectionSkeleton(rows: 6)
                NewJobSectionSkeleton(rows: 2)
                NewJobSectionSkeleton(rows: 1)
                HStack(spacing: 12) {
                    SkeletonView(height: 50, cornerRadius: 16)
                    SkeletonView(height: 50, cornerRadius: 16)
                }
            }
        }
    }
}

struct NewJobSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            SkeletonContainer {
                VStack(spacing: 14) {
                    NewJobSectionSkeleton(rows: 3)
                    NewJobSectionSkeleton(rows: 4)
                    NewJobSectionSkeleton(rows: 2)
                }
            }
            HStack(spacing: 12) {
                SkeletonView(height: 50, cornerRadius: 16)
                SkeletonView(height: 50, cornerRadius: 16)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
        }
    }
}

struct NewJobSectionSkeleton: View {
    let rows: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                CircleSkeletonView(size: 26)
                VStack(alignment: .leading, spacing: 6) {
                    SkeletonView(width: 128, height: 18, cornerRadius: 8)
                    SkeletonView(width: 210, height: 11, cornerRadius: 6, opacity: 0.65)
                }
            }
            ForEach(0..<rows, id: \.self) { index in
                SkeletonView(height: index == rows - 1 ? 88 : 48, cornerRadius: 16)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct DashboardSkeletonCard<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

private struct SettingsSkeletonCard<Content: View>: View {
    let titleWidth: CGFloat
    let iconSize: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                CircleSkeletonView(size: iconSize)
                SkeletonView(width: titleWidth, height: 18, cornerRadius: 8)
            }
            content
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

private struct SettingRowSkeleton: View {
    let valueWidth: CGFloat

    var body: some View {
        HStack {
            SkeletonView(width: 82, height: 12, cornerRadius: 6, opacity: 0.65)
            Spacer()
            SkeletonView(width: valueWidth, height: 14, cornerRadius: 7)
        }
    }
}
