//
//  DailyReminderScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import UserNotifications

struct DailyReminderScreen: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.dailyReminderEnabled) private var dailyReminderEnabled = true
    @AppStorage(AppStorageKeys.dailyReminderHour) private var reminderHour = 18
    @AppStorage(AppStorageKeys.dailyReminderMinute) private var reminderMinute = 0

    @State private var selectedTime = Calendar.current.date(
        bySettingHour: 18,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()

    @State private var statusText = ""

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

                VStack(spacing: AppSpacing.large) {
                    headerView(isPad: isPad, topInset: geo.safeAreaInsets.top)

                    reminderCard(isPad: isPad)

                    if !statusText.isEmpty {
                        Text(statusText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(AppColors.white.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                    }

                    Spacer()
                }
                .padding(.horizontal, isPad ? 40 : 20)
                .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                .frame(maxWidth: isPad ? 650 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            selectedTime = Calendar.current.date(
                bySettingHour: reminderHour,
                minute: reminderMinute,
                second: 0,
                of: Date()
            ) ?? Date()
        }
    }

    private func headerView(isPad: Bool, topInset: CGFloat) -> some View {
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
                Text("Daily Reminder")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Set learning reminder time.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        //.padding(.top, topInset + 18)
    }

    private func reminderCard(isPad: Bool) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: isPad ? 70 : 56, weight: .bold))
                .foregroundStyle(AppColors.secondary)

            Toggle(isOn: $dailyReminderEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Reminder")
                        .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("CurioKids will remind your child every day.")
                        .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .onChange(of: dailyReminderEnabled) { _, newValue in
                if newValue {
                    scheduleReminder()
                } else {
                    cancelReminder()
                }
            }

            DatePicker(
                "Reminder Time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .disabled(!dailyReminderEnabled)

            Button {
                saveTime()
                scheduleReminder()
            } label: {
                Text("Save Reminder")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(dailyReminderEnabled ? AppColors.primary : AppColors.textSecondary.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
            .disabled(!dailyReminderEnabled)
        }
        .padding(isPad ? 30 : 22)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: AppColors.secondary.opacity(0.14), radius: 18, x: 0, y: 10)
    }

    private func saveTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        reminderHour = components.hour ?? 18
        reminderMinute = components.minute ?? 0
    }

    private func scheduleReminder() {
        saveTime()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    createNotification()
                    statusText = "Daily reminder saved successfully."
                } else {
                    dailyReminderEnabled = false
                    statusText = "Notification permission denied. Enable it from Settings."
                }
            }
        }
    }

    private func createNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["curiokids_daily_reminder"])

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let content = UNMutableNotificationContent()
        content.title = "CurioKids Time!"
        content.body = "Ready to learn one fun thing today?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "curiokids_daily_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["curiokids_daily_reminder"])
        statusText = "Daily reminder turned off."
    }
}

#Preview {
    NavigationStack {
        DailyReminderScreen()
    }
}
