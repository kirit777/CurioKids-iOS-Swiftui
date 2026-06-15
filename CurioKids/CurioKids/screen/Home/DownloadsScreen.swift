import SwiftUI

struct DownloadsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var packs: [LearningPack] = LearningPack.defaultPacks

    private var downloadedPacks: [LearningPack] {
        packs.filter { $0.isDownloaded }
    }

    private var storageText: String {
        let totalMB = downloadedPacks.reduce(0) { $0 + estimatedSize(for: $1) }
        return "\(totalMB) MB used"
    }

    private var storageProgress: Double {
        min(Double(downloadedPacks.count) / Double(max(packs.count, 1)), 1.0)
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

                        storageCard(isPad: isPad)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Offline Packs")
                                .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)

                            ForEach(packs) { pack in
                                downloadRow(pack: pack, isPad: isPad)
                            }
                        }
                    }
                    .padding(.horizontal, isPad ? 40 : 20)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                    .frame(maxWidth: isPad ? 760 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadSavedDownloads()
        }
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
                Text("Downloads")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Manage offline learning packs.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func storageCard(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: isPad ? 32 : 26, weight: .bold))
                    .foregroundStyle(AppColors.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Storage Used")
                        .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(downloadedPacks.isEmpty ? "No offline packs downloaded yet." : "Downloaded packs are saved locally on this device.")
                        .font(.system(size: isPad ? 15 : 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }

            ProgressView(value: storageProgress)
                .tint(AppColors.primary)

            Text(storageText)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(isPad ? 24 : 18)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }

    private func downloadRow(pack: LearningPack, isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: pack.icon)
                .font(.system(size: isPad ? 30 : 24, weight: .bold))
                .foregroundStyle(pack.color)
                .frame(width: isPad ? 60 : 52, height: isPad ? 60 : 52)
                .background(pack.color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(pack.title)
                    .font(.system(size: isPad ? 19 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(estimatedSize(for: pack)) MB • \(pack.lessonCount) lessons")
                    .font(.system(size: isPad ? 14 : 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Button {
                if pack.isDownloaded {
                    removePack(pack)
                } else {
                    downloadPack(pack)
                }
            } label: {
                Text(pack.isDownloaded ? "Remove" : "Download")
                    .font(.system(size: isPad ? 14 : 12, weight: .black, design: .rounded))
                    .foregroundStyle(pack.isDownloaded ? AppColors.pink : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(pack.isDownloaded ? AppColors.pink.opacity(0.12) : AppColors.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(isPad ? 18 : 14)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func loadSavedDownloads() {
        for index in packs.indices {
            let key = downloadKey(packs[index].id)
            let isDownloaded = UserDefaults.standard.bool(forKey: key)
            packs[index].isDownloaded = isDownloaded
            packs[index].downloadProgress = isDownloaded ? 1.0 : 0.0
            packs[index].isDownloading = false
        }
    }

    private func downloadPack(_ pack: LearningPack) {
        guard let index = packs.firstIndex(where: { $0.id == pack.id }) else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            packs[index].isDownloaded = true
            packs[index].downloadProgress = 1.0
            packs[index].isDownloading = false
        }

        UserDefaults.standard.set(true, forKey: downloadKey(pack.id))
    }

    private func removePack(_ pack: LearningPack) {
        guard let index = packs.firstIndex(where: { $0.id == pack.id }) else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            packs[index].isDownloaded = false
            packs[index].downloadProgress = 0.0
            packs[index].isDownloading = false
        }

        UserDefaults.standard.set(false, forKey: downloadKey(pack.id))
    }

    private func downloadKey(_ id: String) -> String {
        "downloaded_pack_\(id)"
    }

    private func estimatedSize(for pack: LearningPack) -> Int {
        switch pack.id {
        case "animals": return 42
        case "space": return 36
        case "human_body": return 45
        case "countries": return 51
        case "plants": return 28
        case "vehicles": return 33
        case "science_facts": return 40
        case "famous_places": return 48
        default: return 30
        }
    }
}

#Preview {
    NavigationStack {
        DownloadsScreen()
    }
}
