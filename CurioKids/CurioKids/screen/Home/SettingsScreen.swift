//
//  SettingsScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.childName) private var childName = "Explorer"
    @AppStorage(AppStorageKeys.childAgeGroup) private var childAgeGroup = "4–6"
    @AppStorage(AppStorageKeys.childAvatar) private var childAvatar = "lion.fill"
    @AppStorage(AppStorageKeys.dailyReminderEnabled) private var dailyReminderEnabled = true
    @AppStorage(AppStorageKeys.soundEnabled) private var soundEnabled = true
    @AppStorage(AppStorageKeys.parentLockEnabled) private var parentLockEnabled = true

    private let ageGroups = ["3–4", "4–6", "7–9", "10–12"]
    private let avatars = ["lion.fill", "hare.fill", "tortoise.fill", "bird.fill", "fish.fill", "pawprint.fill"]

    var body: some View {
        GeometryReader { geo in
            let isPad = geo.size.width > 700

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

                        profileSection(isPad: isPad)

                        learningSection(isPad: isPad)

                        safetySection(isPad: isPad)

                        appSection(isPad: isPad)
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    ////.padding(.top, geo.safeAreaInsets.top + 18)
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
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.9))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Manage child profile and app controls.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func profileSection(isPad: Bool) -> some View {
        settingsCard(title: "Child Profile", isPad: isPad) {
            VStack(spacing: 16) {
                TextField("Child name", text: $childName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding()
                    .background(AppColors.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Age Group")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Picker("Age Group", selection: $childAgeGroup) {
                        ForEach(ageGroups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Avatar")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(avatars, id: \.self) { avatar in
                            Button {
                                childAvatar = avatar
                            } label: {
                                Image(systemName: avatar)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(childAvatar == avatar ? .white : AppColors.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(childAvatar == avatar ? AppColors.primary : AppColors.white.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                            }
                        }
                    }
                }
            }
        }
    }

    private func learningSection(isPad: Bool) -> some View {
        settingsCard(title: "Learning", isPad: isPad) {
            VStack(spacing: 12) {
                NavigationLink {
                    DailyReminderScreen()
                } label: {
                    SettingsNavigationRow(
                        title: "Daily Reminder",
                        subtitle: dailyReminderEnabled ? "Reminder is enabled" : "Reminder is disabled",
                        icon: "bell.fill",
                        color: AppColors.secondary
                    )
                }
                .buttonStyle(.plain)
                ToggleRow(title: "Sound Effects", subtitle: "Play friendly app sounds", icon: "speaker.wave.2.fill", color: AppColors.accent, isOn: $soundEnabled)
            }
        }
    }

    private func safetySection(isPad: Bool) -> some View {
        settingsCard(title: "Safety", isPad: isPad) {
            VStack(spacing: 12) {
                ToggleRow(title: "Parent Lock", subtitle: "Protect parent controls", icon: "lock.fill", color: AppColors.green, isOn: $parentLockEnabled)

                NavigationLink {
                    DownloadsScreen()
                } label: {
                    SettingsNavigationRow(title: "Manage Downloads", subtitle: "Offline packs and storage", icon: "square.and.arrow.down.fill", color: AppColors.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func appSection(isPad: Bool) -> some View {
        settingsCard(title: "App", isPad: isPad) {
            VStack(spacing: 12) {
                SettingsNavigationRow(title: "Version", subtitle: "CurioKids 1.0", icon: "info.circle.fill", color: AppColors.textSecondary)
                SettingsNavigationRow(title: "Privacy", subtitle: "Offline-first child-safe learning", icon: "hand.raised.fill", color: AppColors.pink)
            }
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        isPad: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: isPad ? 22 : 18, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            content()
        }
        .padding(isPad ? 22 : 16)
        .background(AppColors.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 46, height: 46)
                .background(color.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(14)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 46, height: 46)
                .background(color.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.55))
        }
        .padding(14)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
