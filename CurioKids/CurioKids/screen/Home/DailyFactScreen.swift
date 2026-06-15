//
//  DailyFactScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct DailyFactScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentFact = DailyFact.samples[0]

    private let facts = DailyFact.samples

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

                    Spacer()

                    factCard(isPad: isPad)

                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            currentFact = facts.randomElement() ?? currentFact
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "shuffle")
                            Text("Show Another Fact")
                        }
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: isPad ? 420 : .infinity)
                        .padding(.vertical, 17)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                    }

                    Spacer()
                }
                .padding(.horizontal, isPad ? 40 : 20)
                .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                .frame(maxWidth: isPad ? 720 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool, topInset: CGFloat) -> some View {
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
                Text("Daily Fact")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("One fun thing to learn today.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
       // .padding(.top, topInset + 18)
    }

    private func factCard(isPad: Bool) -> some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(currentFact.color.opacity(0.16))
                    .frame(width: isPad ? 170 : 135, height: isPad ? 170 : 135)

                Image(systemName: currentFact.icon)
                    .font(.system(size: isPad ? 76 : 58, weight: .bold))
                    .foregroundStyle(currentFact.color)

                Image(systemName: "sparkles")
                    .font(.system(size: isPad ? 30 : 24, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .offset(x: isPad ? 68 : 54, y: isPad ? -62 : -48)
            }

            VStack(spacing: 10) {
                Text(currentFact.title)
                    .font(.system(size: isPad ? 32 : 25, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(currentFact.fact)
                    .font(.system(size: isPad ? 20 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
        }
        .padding(isPad ? 34 : 24)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: currentFact.color.opacity(0.14), radius: 20, x: 0, y: 12)
    }
}

struct DailyFact: Identifiable {
    let id = UUID()
    let title: String
    let fact: String
    let icon: String
    let color: Color

    static let samples: [DailyFact] = [
        .init(
            title: "Octopus Hearts",
            fact: "Octopuses have three hearts and blue blood.",
            icon: "fish.fill",
            color: AppColors.accent
        ),
        .init(
            title: "Amazing Earth",
            fact: "Most of Earth’s surface is covered with water.",
            icon: "globe.asia.australia.fill",
            color: AppColors.green
        ),
        .init(
            title: "The Sun",
            fact: "The Sun is a star that gives Earth light and heat.",
            icon: "sun.max.fill",
            color: AppColors.secondary
        ),
        .init(
            title: "Fast Cheetah",
            fact: "Cheetahs are the fastest land animals.",
            icon: "hare.fill",
            color: AppColors.pink
        )
    ]
}

#Preview {
    NavigationStack {
        DailyFactScreen()
    }
}
