//
//  AchievementsScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct AchievementsScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let achievements = AchievementItem.samples

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

                        summaryCard(isPad: isPad)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(achievements) { item in
                                achievementCard(item, isPad: isPad)
                            }
                        }
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    //.padding(.top, geo.safeAreaInsets.top + 18)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                    .frame(maxWidth: isPad ? 820 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.9))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Achievements")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Celebrate learning milestones.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func summaryCard(isPad: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: isPad ? 50 : 40, weight: .bold))
                .foregroundStyle(AppColors.secondary)
                .frame(width: isPad ? 86 : 70, height: isPad ? 86 : 70)
                .background(AppColors.secondary.opacity(0.16))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("4 Badges Unlocked")
                    .font(.system(size: isPad ? 25 : 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Keep learning to unlock more badges.")
                    .font(.system(size: isPad ? 16 : 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(isPad ? 24 : 18)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }

    private func achievementCard(_ item: AchievementItem, isPad: Bool) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(item.isUnlocked ? item.color.opacity(0.16) : AppColors.textSecondary.opacity(0.10))
                    .frame(width: isPad ? 92 : 74, height: isPad ? 92 : 74)

                Image(systemName: item.icon)
                    .font(.system(size: isPad ? 42 : 34, weight: .bold))
                    .foregroundStyle(item.isUnlocked ? item.color : AppColors.textSecondary.opacity(0.45))
            }

            VStack(spacing: 5) {
                Text(item.title)
                    .font(.system(size: isPad ? 19 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(item.subtitle)
                    .font(.system(size: isPad ? 14 : 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Text(item.isUnlocked ? "Unlocked" : "Locked")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(item.isUnlocked ? AppColors.green : AppColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background((item.isUnlocked ? AppColors.green : AppColors.textSecondary).opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(isPad ? 22 : 16)
        .frame(maxWidth: .infinity)
        .frame(minHeight: isPad ? 230 : 205)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }
}

struct AchievementItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isUnlocked: Bool

    static let samples: [AchievementItem] = [
        .init(title: "First Lesson", subtitle: "Completed one lesson", icon: "book.fill", color: AppColors.primary, isUnlocked: true),
        .init(title: "Quiz Star", subtitle: "Scored well in quiz", icon: "star.fill", color: AppColors.secondary, isUnlocked: true),
        .init(title: "Animal Explorer", subtitle: "Learned animal facts", icon: "pawprint.fill", color: AppColors.green, isUnlocked: true),
        .init(title: "Voice Champ", subtitle: "Answered by voice", icon: "mic.fill", color: AppColors.accent, isUnlocked: true),
        .init(title: "Space Genius", subtitle: "Complete space pack", icon: "moon.stars.fill", color: AppColors.primary, isUnlocked: false),
        .init(title: "Daily Learner", subtitle: "Learn 7 days in a row", icon: "flame.fill", color: AppColors.pink, isUnlocked: false)
    ]
}

#Preview {
    NavigationStack {
        AchievementsScreen()
    }
}
