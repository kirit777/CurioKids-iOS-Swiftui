import SwiftUI

struct HomeScreen: View {
    @AppStorage(AppStorageKeys.childName) private var childName = "Explorer"
    @AppStorage(AppStorageKeys.childAvatar) private var childAvatar = "lion.fill"
    @AppStorage(AppStorageKeys.parentLockEnabled) private var parentLockEnabled = true

    private let quickActions: [HomeQuickAction] = [
        .init(title: "Packs", subtitle: "Start learning", icon: "square.grid.2x2.fill", color: AppColors.primary, destination: .packs),
        .init(title: "Quiz", subtitle: "Test knowledge", icon: "questionmark.circle.fill", color: AppColors.pink, destination: .quiz),
        .init(title: "Draw", subtitle: "Practice skills", icon: "pencil.and.scribble", color: AppColors.green, destination: .drawing),
        .init(title: "AR", subtitle: "Explore 3D", icon: "arkit", color: AppColors.accent, destination: .ar),
        .init(title: "Saved", subtitle: "Favorite lessons", icon: "heart.fill", color: AppColors.pink, destination: .favorites),
        .init(title: "Voice", subtitle: "Speak answers", icon: "mic.fill", color: AppColors.accent, destination: .voiceQuiz),
        .init(title: "Scan", subtitle: "Read pages", icon: "text.viewfinder", color: AppColors.secondary, destination: .scan),
        .init(title: "Image", subtitle: "Learn by photo", icon: "photo.fill", color: AppColors.green, destination: .imageLearning),
        .init(title: "Search", subtitle: "Find lessons", icon: "magnifyingglass", color: AppColors.primary, destination: .search),
        .init(title: "Badges", subtitle: "Achievements", icon: "trophy.fill", color: AppColors.secondary, destination: .achievements),
        .init(title: "Color", subtitle: "Coloring book", icon: "paintpalette.fill", color: AppColors.secondary, destination: .coloringBook)
    ]

    private let learningPacks: [HomeLearningPack] = [
        .init(title: "Animals", icon: "pawprint.fill", color: AppColors.green, progress: 0.35),
        .init(title: "Space", icon: "moon.stars.fill", color: AppColors.primary, progress: 0.18),
        .init(title: "Countries", icon: "globe.asia.australia.fill", color: AppColors.accent, progress: 0.10)
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let isPad = geo.size.width > 700
                let columns = [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ]

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

                            NavigationLink {
                                DailyFactScreen()
                            } label: {
                                dailyFactCard(isPad: isPad)
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 14) {
                                sectionTitle("Quick Start", isPad: isPad)

                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(quickActions) { item in
                                        quickActionCard(item, isPad: isPad)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                sectionTitle("Continue Learning", isPad: isPad)

                                ForEach(learningPacks) { pack in
                                    NavigationLink {
                                        LearningPacksScreen()
                                    } label: {
                                        learningPackRow(pack, isPad: isPad)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            NavigationLink {
                                if parentLockEnabled {
                                    ParentLockScreen()
                                } else {
                                    ParentDashboardScreen()
                                }
                            } label: {
                                parentDashboardCard(isPad: isPad)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, isPad ? 40 : 20)
                        //.padding(.top, geo.safeAreaInsets.top + 18)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                        .frame(maxWidth: isPad ? 760 : .infinity)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.secondary.opacity(0.18))
                    .frame(width: isPad ? 74 : 58, height: isPad ? 74 : 58)

                Image(systemName: childAvatar)
                    .font(.system(size: isPad ? 36 : 28, weight: .bold))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(childName)")
                    .font(.system(size: isPad ? 34 : 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("What shall we explore today?")
                    .font(.system(size: isPad ? 18 : 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
            
            NavigationLink {
                SettingsScreen()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: isPad ? 22 : 18, weight: .bold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
                    .background(AppColors.white.opacity(0.85))
                    .clipShape(Circle())
                    .shadow(color: AppColors.primary.opacity(0.12), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)

//            Image(systemName: "bell.fill")
//                .font(.system(size: isPad ? 22 : 18, weight: .bold))
//                .foregroundStyle(AppColors.primary)
//                .frame(width: isPad ? 52 : 44, height: isPad ? 52 : 44)
//                .background(AppColors.white.opacity(0.85))
//                .clipShape(Circle())
//                .shadow(color: AppColors.primary.opacity(0.12), radius: 12, x: 0, y: 6)
        }
    }

    private func dailyFactCard(isPad: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.secondary.opacity(0.22))
                    .frame(width: isPad ? 82 : 66, height: isPad ? 82 : 66)

                Image(systemName: "lightbulb.fill")
                    .font(.system(size: isPad ? 38 : 30, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Fun Fact")
                    .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Octopuses have three hearts and blue blood.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(isPad ? 24 : 18)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: AppColors.secondary.opacity(0.14), radius: 18, x: 0, y: 10)
    }

    private func quickActionCard(_ item: HomeQuickAction, isPad: Bool) -> some View {
        NavigationLink {
            switch item.destination {
            case .packs:
                LearningPacksScreen()
            case .quiz:
                QuizModeScreen()
            case .drawing:
                DrawingPracticeScreen()
            case .ar:
                ARExploreScreen()
            case .favorites:
                FavoritesScreen()
            case .voiceQuiz:
                VoiceAnswerQuizScreen()
            case .scan:
                ScanLearnOCRScreen()
            case .imageLearning:
                ImageLearningScreen()
            case .search:
                SearchLessonsScreen()
            case .achievements:
                AchievementsScreen()
            case .coloringBook:
                ColoringBookScreen()
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(item.color.opacity(0.16))
                        .frame(width: isPad ? 62 : 52, height: isPad ? 62 : 52)

                    Image(systemName: item.icon)
                        .font(.system(size: isPad ? 30 : 24, weight: .bold))
                        .foregroundStyle(item.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(item.subtitle)
                        .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(isPad ? 22 : 16)
            .background(AppColors.white.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .shadow(color: item.color.opacity(0.12), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func learningPackRow(_ pack: HomeLearningPack, isPad: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(pack.color.opacity(0.14))
                    .frame(width: isPad ? 68 : 56, height: isPad ? 68 : 56)

                Image(systemName: pack.icon)
                    .font(.system(size: isPad ? 32 : 25, weight: .bold))
                    .foregroundStyle(pack.color)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pack.title)
                        .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Text("\(Int(pack.progress * 100))%")
                        .font(.system(size: isPad ? 15 : 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }

                ProgressView(value: pack.progress)
                    .tint(pack.color)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.7))
        }
        .padding(isPad ? 20 : 16)
        .background(AppColors.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func parentDashboardCard(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "person.2.badge.gearshape.fill")
                .font(.system(size: isPad ? 34 : 27, weight: .bold))
                .foregroundStyle(AppColors.primary)

            VStack(alignment: .leading, spacing: 5) {
                Text("Parent Dashboard")
                    .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("View progress, downloads, and safety controls.")
                    .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppColors.green)
        }
        .padding(isPad ? 22 : 16)
        .background(AppColors.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func sectionTitle(_ title: String, isPad: Bool) -> some View {
        Text(title)
            .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
}

enum HomeDestination {
    case packs
    case quiz
    case drawing
    case ar
    case favorites
    case voiceQuiz
    case scan
    case imageLearning
    case search
    case achievements
    case coloringBook
}

struct HomeQuickAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: HomeDestination
}

struct HomeLearningPack: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let progress: Double
}

#Preview {
    HomeScreen()
}
