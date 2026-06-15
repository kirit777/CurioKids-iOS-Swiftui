//
//  SearchLessonsScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct SearchLessonsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    private let lessons = SearchLesson.samples

    private var filteredLessons: [SearchLesson] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return lessons
        }

        return lessons.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.packName.localizedCaseInsensitiveContains(searchText) ||
            $0.keywords.localizedCaseInsensitiveContains(searchText)
        }
    }

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

                        searchBar(isPad: isPad)

                        if filteredLessons.isEmpty {
                            emptyView(isPad: isPad)
                        } else {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Lessons")
                                    .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AppColors.textPrimary)

                                ForEach(filteredLessons) { lesson in
                                    lessonRow(lesson, isPad: isPad)
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
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.9))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Search Lessons")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Find animals, planets, countries, and more.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func searchBar(isPad: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)

            TextField("Search lessons...", text: $searchText)
                .font(.system(size: isPad ? 18 : 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                }
            }
        }
        .padding(isPad ? 18 : 15)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .shadow(color: AppColors.primary.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private func lessonRow(_ lesson: SearchLesson, isPad: Bool) -> some View {
        NavigationLink {
            TopicDetailScreen(
                topic: PackTopic(
                    title: lesson.title,
                    subtitle: lesson.subtitle,
                    icon: lesson.icon,
                    color: lesson.color,
                    isCompleted: false
                ),
                pack: LearningPack(
                    id: lesson.packName.lowercased().replacingOccurrences(of: " ", with: "_"),
                    title: lesson.packName,
                    subtitle: lesson.packSubtitle,
                    icon: lesson.packIcon,
                    color: lesson.color,
                    lessonCount: lesson.lessonCount,
                    isDownloaded: true,
                    isDownloading: false,
                    downloadProgress: 1.0,
                    progress: 0.2
                )
            )
        } label: {
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

                    Text("\(lesson.packName) • \(lesson.subtitle)")
                        .font(.system(size: isPad ? 14 : 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.55))
            }
            .padding(isPad ? 18 : 14)
            .background(AppColors.white.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func emptyView(isPad: Bool) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: isPad ? 78 : 60, weight: .bold))
                .foregroundStyle(AppColors.primary)

            Text("No Lesson Found")
                .font(.system(size: isPad ? 30 : 24, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text("Try searching for lion, earth, India, plants, sun, or vehicles.")
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

struct SearchLesson: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let packName: String
    let packSubtitle: String
    let packIcon: String
    let lessonCount: Int
    let icon: String
    let color: Color
    let keywords: String

    static let samples: [SearchLesson] = [
        .init(title: "Lion", subtitle: "King of the jungle", packName: "Animals", packSubtitle: "Wildlife and pets", packIcon: "pawprint.fill", lessonCount: 24, icon: "pawprint.fill", color: AppColors.green, keywords: "animal wild cat roar cub"),
        .init(title: "Elephant", subtitle: "Largest land animal", packName: "Animals", packSubtitle: "Wildlife and pets", packIcon: "pawprint.fill", lessonCount: 24, icon: "hare.fill", color: AppColors.green, keywords: "animal trunk big wildlife"),
        .init(title: "Earth", subtitle: "Our home planet", packName: "Space", packSubtitle: "Planets and stars", packIcon: "moon.stars.fill", lessonCount: 18, icon: "globe.asia.australia.fill", color: AppColors.accent, keywords: "planet space water moon"),
        .init(title: "Sun", subtitle: "Our nearest star", packName: "Space", packSubtitle: "Planets and stars", packIcon: "moon.stars.fill", lessonCount: 18, icon: "sun.max.fill", color: AppColors.secondary, keywords: "star light heat space"),
        .init(title: "India", subtitle: "Culture and colors", packName: "Countries", packSubtitle: "Flags and capitals", packIcon: "globe.asia.australia.fill", lessonCount: 30, icon: "flag.fill", color: AppColors.primary, keywords: "country capital delhi taj mahal"),
        .init(title: "Plants", subtitle: "Trees and flowers", packName: "Plants", packSubtitle: "Nature learning", packIcon: "leaf.fill", lessonCount: 16, icon: "leaf.fill", color: AppColors.green, keywords: "tree flower sunlight nature")
    ]
}

#Preview {
    NavigationStack {
        SearchLessonsScreen()
    }
}
