//
//  PackDetailScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct PackDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    let pack: LearningPack

    private var topics: [PackTopic] {
        switch pack.title {
        case "Animals":
            return [
                .init(title: "Lion", subtitle: "King of the jungle", icon: "pawprint.fill", color: AppColors.secondary, isCompleted: true),
                .init(title: "Elephant", subtitle: "Largest land animal", icon: "hare.fill", color: AppColors.green, isCompleted: false),
                .init(title: "Dolphin", subtitle: "Smart sea animal", icon: "fish.fill", color: AppColors.accent, isCompleted: false),
                .init(title: "Eagle", subtitle: "Powerful flying bird", icon: "bird.fill", color: AppColors.primary, isCompleted: false)
            ]

        case "Space":
            return [
                .init(title: "Sun", subtitle: "Our nearest star", icon: "sun.max.fill", color: AppColors.secondary, isCompleted: true),
                .init(title: "Earth", subtitle: "Our home planet", icon: "globe.asia.australia.fill", color: AppColors.accent, isCompleted: false),
                .init(title: "Moon", subtitle: "Earth’s natural satellite", icon: "moon.stars.fill", color: AppColors.primary, isCompleted: false),
                .init(title: "Mars", subtitle: "The red planet", icon: "circle.fill", color: AppColors.pink, isCompleted: false)
            ]

        case "Countries":
            return [
                .init(title: "India", subtitle: "Land of culture and colors", icon: "flag.fill", color: AppColors.secondary, isCompleted: true),
                .init(title: "Japan", subtitle: "Country of rising sun", icon: "globe.asia.australia.fill", color: AppColors.pink, isCompleted: false),
                .init(title: "France", subtitle: "Famous for Eiffel Tower", icon: "building.columns.fill", color: AppColors.primary, isCompleted: false),
                .init(title: "Brazil", subtitle: "Rainforests and football", icon: "leaf.fill", color: AppColors.green, isCompleted: false)
            ]

        default:
            return [
                .init(title: "Introduction", subtitle: "Start this learning pack", icon: pack.icon, color: pack.color, isCompleted: false),
                .init(title: "Fun Facts", subtitle: "Learn interesting facts", icon: "lightbulb.fill", color: AppColors.secondary, isCompleted: false),
                .init(title: "Picture Learning", subtitle: "Learn with images", icon: "photo.fill", color: AppColors.accent, isCompleted: false),
                .init(title: "Quick Quiz", subtitle: "Check what you learned", icon: "questionmark.circle.fill", color: AppColors.pink, isCompleted: false)
            ]
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

                        packHeroCard(isPad: isPad)

                        actionGrid(isPad: isPad)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Topics")
                                .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)

                            ForEach(topics) { topic in
                                NavigationLink {
                                    TopicDetailScreen(topic: topic, pack: pack)
                                } label: {
                                    topicRow(topic, isPad: isPad)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    //.padding(.top, geo.safeAreaInsets.top + 18)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 28)
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
                    .background(AppColors.white.opacity(0.86))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pack.title)
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(pack.lessonCount) lessons • Offline pack")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func packHeroCard(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(pack.color.opacity(0.16))
                        .frame(width: isPad ? 96 : 76, height: isPad ? 96 : 76)

                    Image(systemName: pack.icon)
                        .font(.system(size: isPad ? 46 : 36, weight: .bold))
                        .foregroundStyle(pack.color)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(pack.subtitle)
                        .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(pack.isDownloaded ? "Ready for offline learning" : "Download this pack to use offline")
                        .font(.system(size: isPad ? 16 : 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    Text("\(Int(pack.progress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(pack.color)
                }

                ProgressView(value: pack.progress)
                    .tint(pack.color)
            }
        }
        .padding(isPad ? 26 : 20)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: pack.color.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private func actionGrid(isPad: Bool) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            NavigationLink {
                TopicDetailScreen(topic: topics.first ?? PackTopic(
                    title: "Introduction",
                    subtitle: "Start this learning pack",
                    icon: pack.icon,
                    color: pack.color,
                    isCompleted: false
                ), pack: pack)
            } label: {
                detailAction("Start Lesson", "play.fill", AppColors.primary, isPad: isPad)
            }
            .buttonStyle(.plain)

            NavigationLink {
                QuizModeScreen()
            } label: {
                detailAction("Quiz", "questionmark.circle.fill", AppColors.pink, isPad: isPad)
            }
            .buttonStyle(.plain)

            NavigationLink {
                ReadAloudScreen()
            } label: {
                detailAction("Read Aloud", "speaker.wave.2.fill", AppColors.accent, isPad: isPad)
            }
            .buttonStyle(.plain)

            NavigationLink {
                DrawingPracticeScreen()
            } label: {
                detailAction("Draw", "pencil.and.scribble", AppColors.green, isPad: isPad)
            }
            .buttonStyle(.plain)
        }
    }

    private func detailAction(_ title: String, _ icon: String, _ color: Color, isPad: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: isPad ? 22 : 18, weight: .bold))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: isPad ? 17 : 14, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()
        }
        .padding(isPad ? 18 : 14)
        .background(AppColors.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func topicRow(_ topic: PackTopic, isPad: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(topic.color.opacity(0.15))
                    .frame(width: isPad ? 64 : 54, height: isPad ? 64 : 54)

                Image(systemName: topic.icon)
                    .font(.system(size: isPad ? 30 : 24, weight: .bold))
                    .foregroundStyle(topic.color)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(topic.title)
                    .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(topic.subtitle)
                    .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: topic.isCompleted ? "checkmark.circle.fill" : "chevron.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(topic.isCompleted ? AppColors.green : AppColors.textSecondary.opacity(0.6))
        }
        .padding(isPad ? 18 : 14)
        .background(AppColors.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }
}

struct PackTopic: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isCompleted: Bool
}

//#Preview {
//    NavigationStack {
//        PackDetailScreen(
//            pack: LearningPack(
//                title: "Animals",
//                subtitle: "Wildlife, pets, birds, sea animals",
//                icon: "pawprint.fill",
//                color: AppColors.green,
//                lessonCount: 24,
//                isDownloaded: true,
//                progress: 0.35
//            )
//        )
//    }
//}
