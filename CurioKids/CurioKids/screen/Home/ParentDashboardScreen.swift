//
//  ParentDashboardScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct ParentDashboardScreen: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.childName) private var childName = "Explorer"
    @AppStorage(AppStorageKeys.childAgeGroup) private var childAgeGroup = "4–6"
    @AppStorage(AppStorageKeys.childAvatar) private var childAvatar = "lion.fill"

    private let stats: [ParentStat] = [
        .init(title: "Lessons", value: "7", icon: "book.pages.fill", color: AppColors.primary),
        .init(title: "Quiz Score", value: "82%", icon: "checkmark.seal.fill", color: AppColors.green),
        .init(title: "Time Today", value: "24m", icon: "clock.fill", color: AppColors.secondary),
        .init(title: "Packs", value: "3", icon: "square.grid.2x2.fill", color: AppColors.accent)
    ]

    private let activities: [ParentActivity] = [
        .init(title: "Completed Lion lesson", subtitle: "Animals Pack", icon: "pawprint.fill", color: AppColors.green),
        .init(title: "Scored 3/4 in Quiz", subtitle: "General Quiz", icon: "questionmark.circle.fill", color: AppColors.pink),
        .init(title: "Practiced Letter A", subtitle: "Drawing Practice", icon: "pencil.and.scribble", color: AppColors.primary)
    ]

    var body: some View {
        GeometryReader { geo in
            let isPad = geo.size.width > 700
            let columns = [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ]

            ZStack {
                LinearGradient(
                    colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.large) {
                        headerView(isPad: isPad)

                        childCard(isPad: isPad)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(stats) { stat in
                                statCard(stat, isPad: isPad)
                            }
                        }

                        controlsSection(isPad: isPad)

                        recentActivitySection(isPad: isPad)
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    //.padding(.top, geo.safeAreaInsets.top + 18)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                    .frame(maxWidth: isPad ? 760 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.9))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Parent Dashboard")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Progress, safety, and learning controls.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func childCard(isPad: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.secondary.opacity(0.18))
                    .frame(width: isPad ? 86 : 70, height: isPad ? 86 : 70)

                Image(systemName: childAvatar)
                    .font(.system(size: isPad ? 42 : 34, weight: .bold))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(childName)
                    .font(.system(size: isPad ? 26 : 21, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Age Group: \(childAgeGroup)")
                    .font(.system(size: isPad ? 16 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(isPad ? 24 : 18)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: AppColors.primary.opacity(0.10), radius: 16, x: 0, y: 8)
    }

    private func statCard(_ stat: ParentStat, isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: stat.icon)
                .font(.system(size: isPad ? 32 : 26, weight: .bold))
                .foregroundStyle(stat.color)

            Text(stat.value)
                .font(.system(size: isPad ? 32 : 26, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text(stat.title)
                .font(.system(size: isPad ? 16 : 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(isPad ? 22 : 16)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func controlsSection(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Controls", isPad: isPad)

           // controlRow("Screen Time Limit", "Set daily learning time", "timer", AppColors.secondary, isPad: isPad)
            NavigationLink {
                ScreenTimeLimitScreen()
            } label: {
                controlRow("Screen Time Limit", "Set daily learning time", "timer", AppColors.secondary, isPad: isPad)
            }
            .buttonStyle(.plain)
            
            NavigationLink {
                DownloadsScreen()
            } label: {
                controlRow("Downloaded Packs", "Manage offline packs", "square.and.arrow.down.fill", AppColors.primary, isPad: isPad)
            }
            .buttonStyle(.plain)
            
            NavigationLink {
                ResetProgressScreen()
            } label: {
                controlRow("Reset Progress", "Clear child learning progress", "arrow.counterclockwise", AppColors.pink, isPad: isPad)
            }
            .buttonStyle(.plain)
            //controlRow("Reset Progress", "Clear child learning progress", "arrow.counterclockwise", AppColors.pink, isPad: isPad)
        }
    }

    private func controlRow(_ title: String, _ subtitle: String, _ icon: String, _ color: Color, isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: isPad ? 26 : 22, weight: .bold))
                .foregroundStyle(color)
                .frame(width: isPad ? 54 : 46, height: isPad ? 54 : 46)
                .background(color.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
        }
        .padding(isPad ? 18 : 14)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func recentActivitySection(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Recent Activity", isPad: isPad)

            ForEach(activities) { activity in
                HStack(spacing: 14) {
                    Image(systemName: activity.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(activity.color)
                        .frame(width: 46, height: 46)
                        .background(activity.color.opacity(0.13))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.title)
                            .font(.system(size: isPad ? 17 : 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(activity.subtitle)
                            .font(.system(size: isPad ? 14 : 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .padding(isPad ? 18 : 14)
                .background(AppColors.white.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
        }
    }

    private func sectionTitle(_ title: String, isPad: Bool) -> some View {
        Text(title)
            .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
}

struct ParentStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct ParentActivity: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

#Preview {
    NavigationStack {
        ParentDashboardScreen()
    }
}
