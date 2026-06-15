//
//  OnboardingScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct OnboardingScreen: View {
    let onFinish: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        .init(
            icon: "sparkles",
            title: "Welcome to CurioKids",
            subtitle: "A colorful offline learning world for curious children.",
            color: AppColors.primary
        ),
        .init(
            icon: "book.pages.fill",
            title: "Learn with Pictures",
            subtitle: "Explore animals, space, countries, plants, vehicles, and science facts.",
            color: AppColors.accent
        ),
        .init(
            icon: "speaker.wave.2.fill",
            title: "Listen, Speak & Play",
            subtitle: "Lessons can be read aloud, and kids can answer quizzes by voice.",
            color: AppColors.pink
        ),
        .init(
            icon: "square.and.arrow.down.fill",
            title: "Use Learning Packs Offline",
            subtitle: "Download packs once and keep learning without internet.",
            color: AppColors.green
        )
    ]

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

                VStack(spacing: 0) {
                    HStack {
                        Spacer()

                        Button {
                            onFinish()
                        } label: {
                            Text("Skip")
                                .font(.system(size: isPad ? 18 : 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.textSecondary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(AppColors.white.opacity(0.75))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.top, geo.safeAreaInsets.top + 12)

                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                isPad: isPad
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    VStack(spacing: 22) {
                        HStack(spacing: 8) {
                            ForEach(pages.indices, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? AppColors.primary : AppColors.textSecondary.opacity(0.22))
                                    .frame(width: index == currentPage ? 28 : 9, height: 9)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentPage)
                            }
                        }

                        Button {
                            if currentPage == pages.count - 1 {
                                onFinish()
                            } else {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    currentPage += 1
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(currentPage == pages.count - 1 ? "Start Setup" : "Next")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: isPad ? 20 : 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: isPad ? 420 : .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                            .shadow(color: AppColors.primary.opacity(0.25), radius: 18, x: 0, y: 10)
                        }
                    }
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 26)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isPad: Bool

    var body: some View {
        VStack(spacing: AppSpacing.extraLarge) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.white.opacity(0.85))
                    .frame(width: isPad ? 270 : 210, height: isPad ? 270 : 210)
                    .shadow(color: page.color.opacity(0.18), radius: 24, x: 0, y: 14)

                Circle()
                    .fill(page.color.opacity(0.14))
                    .frame(width: isPad ? 210 : 160, height: isPad ? 210 : 160)

                Image(systemName: page.icon)
                    .font(.system(size: isPad ? 92 : 70, weight: .bold))
                    .foregroundStyle(page.color)

                Image(systemName: "star.fill")
                    .font(.system(size: isPad ? 34 : 26, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .offset(x: isPad ? 95 : 76, y: isPad ? -92 : -72)

                Image(systemName: "heart.fill")
                    .font(.system(size: isPad ? 30 : 22, weight: .bold))
                    .foregroundStyle(AppColors.pink)
                    .offset(x: isPad ? -92 : -72, y: isPad ? 88 : 68)
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: isPad ? 42 : 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(size: isPad ? 21 : 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(maxWidth: isPad ? 560 : 340)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.large)
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

#Preview {
    OnboardingScreen {}
}
