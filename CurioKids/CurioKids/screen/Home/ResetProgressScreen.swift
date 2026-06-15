//
//  ResetProgressScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct ResetProgressScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmAlert = false
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

                    resetCard(isPad: isPad)

                    if !statusText.isEmpty {
                        Text(statusText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.green)
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
        .alert("Reset all progress?", isPresented: $showConfirmAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("This will clear completed lessons, scores, and saved learning progress.")
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
                Text("Reset Progress")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Clear learning progress safely.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        //.padding(.top, topInset + 18)
    }

    private func resetCard(isPad: Bool) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: isPad ? 78 : 62, weight: .bold))
                .foregroundStyle(AppColors.pink)

            VStack(spacing: 8) {
                Text("Start Fresh")
                    .font(.system(size: isPad ? 30 : 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("This will remove completed lessons, quiz scores, and saved progress. Downloads and profile settings will stay safe.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                showConfirmAlert = true
            } label: {
                Text("Reset Learning Progress")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(AppColors.pink)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
        }
        .padding(isPad ? 30 : 22)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: AppColors.pink.opacity(0.14), radius: 18, x: 0, y: 10)
    }

    private func resetProgress() {
        let defaults = UserDefaults.standard

        for key in defaults.dictionaryRepresentation().keys {
            if key.hasPrefix("completed_") ||
                key.hasPrefix("quiz_score_") ||
                key.hasPrefix("lesson_progress_") {
                defaults.removeObject(forKey: key)
            }
        }

        statusText = "Learning progress has been reset."
    }
}

#Preview {
    NavigationStack {
        ResetProgressScreen()
    }
}
