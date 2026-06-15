//
//  Constants.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//

import SwiftUI

enum AppConstants {
    static let appName = "CurioKids"
    static let appTagline = "Offline Learning Explorer"
}

enum AppStorageKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let childName = "childName"
    static let childAgeGroup = "childAgeGroup"
    static let childAvatar = "childAvatar"
    static let parentPIN = "parentPIN"
    static let dailyReminderEnabled = "dailyReminderEnabled"
    static let soundEnabled = "soundEnabled"
    static let parentLockEnabled = "parentLockEnabled"
    static let dailyReminderHour = "dailyReminderHour"
    static let dailyReminderMinute = "dailyReminderMinute"
    static let screenTimeLimitEnabled = "screenTimeLimitEnabled"
    static let screenTimeLimitMinutes = "screenTimeLimitMinutes"
}

enum AppColors {
    static let primary = Color(hex: "#6C63FF")
    static let secondary = Color(hex: "#FFB703")
    static let accent = Color(hex: "#00B4D8")
    static let pink = Color(hex: "#FF6B9A")
    static let green = Color(hex: "#52B788")
    static let backgroundTop = Color(hex: "#FFF8E7")
    static let backgroundBottom = Color(hex: "#EAF7FF")
    static let textPrimary = Color(hex: "#243047")
    static let textSecondary = Color(hex: "#6B7280")
    static let white = Color.white
}

enum AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 36
}

enum AppRadius {
    static let medium: CGFloat = 18
    static let large: CGFloat = 28
    static let extraLarge: CGFloat = 36
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
