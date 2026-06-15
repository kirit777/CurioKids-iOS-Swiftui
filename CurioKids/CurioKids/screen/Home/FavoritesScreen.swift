//
//  FavoritesScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct FavoritesScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var favorites = FavoriteLesson.samples

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

                        if favorites.isEmpty {
                            emptyView(isPad: isPad)
                        } else {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Saved Lessons")
                                    .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AppColors.textPrimary)

                                ForEach(favorites) { lesson in
                                    favoriteRow(lesson, isPad: isPad)
                                }
                            }
                        }
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
                Text("Favorites")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Quickly open saved lessons.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func favoriteRow(_ lesson: FavoriteLesson, isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: lesson.icon)
                .font(.system(size: isPad ? 30 : 24, weight: .bold))
                .foregroundStyle(lesson.color)
                .frame(width: isPad ? 60 : 52, height: isPad ? 60 : 52)
                .background(lesson.color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(lesson.title)
                    .font(.system(size: isPad ? 19 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(lesson.packName)
                    .font(.system(size: isPad ? 14 : 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Button {
                favorites.removeAll { $0.id == lesson.id }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColors.pink)
                    .frame(width: 44, height: 44)
                    .background(AppColors.pink.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .padding(isPad ? 18 : 14)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func emptyView(isPad: Bool) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "heart")
                .font(.system(size: isPad ? 78 : 60, weight: .bold))
                .foregroundStyle(AppColors.pink)

            Text("No Favorites Yet")
                .font(.system(size: isPad ? 30 : 24, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text("Save lessons you like and they will appear here.")
                .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(isPad ? 34 : 24)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }
}

struct FavoriteLesson: Identifiable {
    let id = UUID()
    let title: String
    let packName: String
    let icon: String
    let color: Color

    static let samples: [FavoriteLesson] = [
        .init(title: "Lion", packName: "Animals Pack", icon: "pawprint.fill", color: AppColors.green),
        .init(title: "Earth", packName: "Space Pack", icon: "globe.asia.australia.fill", color: AppColors.accent),
        .init(title: "India", packName: "Countries Pack", icon: "flag.fill", color: AppColors.secondary)
    ]
}

#Preview {
    NavigationStack {
        FavoritesScreen()
    }
}
