//
//  ScreenTimeLimitScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct ScreenTimeLimitScreen: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.screenTimeLimitEnabled) private var limitEnabled = true
    @AppStorage(AppStorageKeys.screenTimeLimitMinutes) private var limitMinutes = 30

    private let limits = [10, 15, 20, 30, 45, 60, 90]

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

                    limitCard(isPad: isPad)

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
                Text("Screen Time")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Set daily learning time limit.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
       // .padding(.top, topInset + 18)
    }

    private func limitCard(isPad: Bool) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "timer")
                .font(.system(size: isPad ? 74 : 58, weight: .bold))
                .foregroundStyle(AppColors.secondary)

            Toggle(isOn: $limitEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Time Limit")
                        .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Help kids learn with healthy daily limits.")
                        .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Daily Limit")
                    .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(limits, id: \.self) { minute in
                        Button {
                            limitMinutes = minute
                        } label: {
                            Text("\(minute) min")
                                .font(.system(size: isPad ? 17 : 14, weight: .black, design: .rounded))
                                .foregroundStyle(limitMinutes == minute ? .white : AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(limitMinutes == minute ? AppColors.primary : AppColors.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        }
                        .disabled(!limitEnabled)
                        .opacity(limitEnabled ? 1 : 0.45)
                    }
                }
            }

            Text(limitEnabled ? "Current limit: \(limitMinutes) minutes per day" : "Screen time limit is disabled")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(isPad ? 30 : 22)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: AppColors.secondary.opacity(0.14), radius: 18, x: 0, y: 10)
    }
}

#Preview {
    NavigationStack {
        ScreenTimeLimitScreen()
    }
}
