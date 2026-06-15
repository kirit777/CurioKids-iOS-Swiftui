//
//  ImageLearningScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import PhotosUI
import UIKit

struct ImageLearningScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var resultTitle = ""
    @State private var resultText = ""

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

                        pickerCard(isPad: isPad)

                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: isPad ? 380 : 280)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
                                .shadow(color: AppColors.primary.opacity(0.12), radius: 16, x: 0, y: 8)
                        }

                        if !resultText.isEmpty {
                            resultCard(isPad: isPad)
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
        .onChange(of: selectedItem) { _, newItem in
            loadImage(newItem)
        }
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
                Text("Image Learning")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Pick a picture and learn from it.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func pickerCard(isPad: Bool) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: isPad ? 72 : 56, weight: .bold))
                .foregroundStyle(AppColors.primary)

            Text("Choose any animal, planet, place, or object image.")
                .font(.system(size: isPad ? 22 : 18, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack(spacing: 10) {
                    Image(systemName: "photo.fill")
                    Text("Pick Image")
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
        }
        .padding(isPad ? 30 : 22)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }

    private func resultCard(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(AppColors.secondary)

                Text(resultTitle)
                    .font(.system(size: isPad ? 22 : 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }

            Text(resultText)
                .font(.system(size: isPad ? 17 : 14.5, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(5)
        }
        .padding(isPad ? 24 : 18)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func loadImage(_ item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }

            await MainActor.run {
                selectedImage = image
                generateSimpleLearningText()
            }
        }
    }

    private func generateSimpleLearningText() {
        let samples = [
            ("Look Carefully", "This image can help you observe shapes, colors, and details. Try asking: What do I see? What color is it? Is it living or non-living?"),
            ("Learning Tip", "Pictures make learning easier. Look at the main object, describe it in your own words, and remember one interesting fact about it."),
            ("Explore More", "Try to identify the object in this image. Then think about where it is found, how it is used, and what makes it special.")
        ]

        let selected = samples.randomElement() ?? samples[0]
        resultTitle = selected.0
        resultText = selected.1
    }
}

#Preview {
    NavigationStack {
        ImageLearningScreen()
    }
}
