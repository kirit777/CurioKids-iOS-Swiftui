import SwiftUI

struct LearningPacksScreen: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var downloadManager = PackDownloadManager()

    var body: some View {
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

                        infoCard(isPad: isPad)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(downloadManager.packs) { pack in
                                packCard(pack, isPad: isPad)
                            }
                        }
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                    .frame(maxWidth: isPad ? 820 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
                Text("Learning Packs")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Download once, learn offline anytime.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func infoCard(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "square.and.arrow.down.fill")
                .font(.system(size: isPad ? 34 : 28, weight: .bold))
                .foregroundStyle(AppColors.primary)

            VStack(alignment: .leading, spacing: 5) {
                Text("Offline Learning")
                    .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Tap Download. Pack status will be saved locally using UserDefaults.")
                    .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(isPad ? 22 : 16)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .shadow(color: AppColors.primary.opacity(0.10), radius: 16, x: 0, y: 8)
    }

    private func packCard(_ pack: LearningPack, isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(pack.color.opacity(0.16))
                        .frame(width: isPad ? 64 : 54, height: isPad ? 64 : 54)

                    Image(systemName: pack.icon)
                        .font(.system(size: isPad ? 31 : 25, weight: .bold))
                        .foregroundStyle(pack.color)
                }

                Spacer()

                Image(systemName: pack.isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: isPad ? 25 : 21, weight: .bold))
                    .foregroundStyle(pack.isDownloaded ? AppColors.green : AppColors.textSecondary.opacity(0.55))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(pack.title)
                    .font(.system(size: isPad ? 22 : 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(pack.subtitle)
                    .font(.system(size: isPad ? 15 : 12.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Text("\(pack.lessonCount) lessons")
                .font(.system(size: isPad ? 14 : 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)

            if pack.isDownloading {
                ProgressView(value: pack.downloadProgress)
                    .tint(pack.color)

                Text("Downloading \(Int(pack.downloadProgress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(pack.color)
            } else if pack.isDownloaded {
                NavigationLink {
                    PackDetailScreen(pack: pack)
                } label: {
                    Text("Open Pack")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(pack.color)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    downloadManager.removePack(pack)
                } label: {
                    Text("Remove Download")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.pink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.pink.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                }
            } else {
                Button {
                    downloadManager.downloadPack(pack)
                } label: {
                    Text("Download")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                }
            }
        }
        .padding(isPad ? 22 : 16)
        .frame(maxWidth: .infinity, minHeight: isPad ? 260 : 235, alignment: .topLeading)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .shadow(color: pack.color.opacity(0.10), radius: 14, x: 0, y: 8)
    }
}

import Combine

final class PackDownloadManager: ObservableObject {
    @Published var packs: [LearningPack] = LearningPack.defaultPacks

    init() {
        loadSavedDownloads()
    }

    func downloadPack(_ pack: LearningPack) {
        guard let index = packs.firstIndex(where: { $0.id == pack.id }) else { return }

        packs[index].isDownloading = true
        packs[index].downloadProgress = 0

        Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { timer in
            DispatchQueue.main.async {
                guard let currentIndex = self.packs.firstIndex(where: { $0.id == pack.id }) else {
                    timer.invalidate()
                    return
                }

                self.packs[currentIndex].downloadProgress += 0.08

                if self.packs[currentIndex].downloadProgress >= 1 {
                    self.packs[currentIndex].downloadProgress = 1
                    self.packs[currentIndex].isDownloading = false
                    self.packs[currentIndex].isDownloaded = true
                    self.saveDownloadStatus(for: self.packs[currentIndex])
                    timer.invalidate()
                }
            }
        }
    }

    func removePack(_ pack: LearningPack) {
        guard let index = packs.firstIndex(where: { $0.id == pack.id }) else { return }

        packs[index].isDownloaded = false
        packs[index].isDownloading = false
        packs[index].downloadProgress = 0

        UserDefaults.standard.set(false, forKey: downloadKey(pack.id))
    }

    private func loadSavedDownloads() {
        for index in packs.indices {
            packs[index].isDownloaded = UserDefaults.standard.bool(forKey: downloadKey(packs[index].id))
            packs[index].downloadProgress = packs[index].isDownloaded ? 1 : 0
        }
    }

    private func saveDownloadStatus(for pack: LearningPack) {
        UserDefaults.standard.set(pack.isDownloaded, forKey: downloadKey(pack.id))
    }

    private func downloadKey(_ id: String) -> String {
        "downloaded_pack_\(id)"
    }
}

struct LearningPack: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let lessonCount: Int

    var isDownloaded: Bool
    var isDownloading: Bool
    var downloadProgress: Double
    var progress: Double

    static let defaultPacks: [LearningPack] = [
        .init(id: "animals", title: "Animals", subtitle: "Wildlife, pets, birds, sea animals", icon: "pawprint.fill", color: AppColors.green, lessonCount: 24, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.35),
        .init(id: "space", title: "Space", subtitle: "Planets, moon, stars, astronauts", icon: "moon.stars.fill", color: AppColors.primary, lessonCount: 18, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.18),
        .init(id: "human_body", title: "Human Body", subtitle: "Organs, bones, senses, health", icon: "figure.child", color: AppColors.pink, lessonCount: 20, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.0),
        .init(id: "countries", title: "Countries", subtitle: "Flags, capitals, maps, cultures", icon: "globe.asia.australia.fill", color: AppColors.accent, lessonCount: 30, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.10),
        .init(id: "plants", title: "Plants", subtitle: "Trees, flowers, fruits, nature", icon: "leaf.fill", color: AppColors.green, lessonCount: 16, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.0),
        .init(id: "vehicles", title: "Vehicles", subtitle: "Cars, trains, planes, ships", icon: "car.fill", color: AppColors.secondary, lessonCount: 22, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.0),
        .init(id: "science_facts", title: "Science Facts", subtitle: "Simple experiments and cool facts", icon: "atom", color: AppColors.primary, lessonCount: 26, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.0),
        .init(id: "famous_places", title: "Famous Places", subtitle: "Monuments, wonders, landmarks", icon: "building.columns.fill", color: AppColors.pink, lessonCount: 21, isDownloaded: false, isDownloading: false, downloadProgress: 0, progress: 0.0)
    ]
}

#Preview {
    NavigationStack {
        LearningPacksScreen()
    }
}
