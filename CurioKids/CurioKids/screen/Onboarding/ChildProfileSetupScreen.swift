//
//  ChildProfileSetupScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct ChildProfileSetupScreen: View {
    let onContinue: () -> Void

    @AppStorage(AppStorageKeys.childName) private var storedChildName = ""
    @AppStorage(AppStorageKeys.childAgeGroup) private var storedAgeGroup = ""
    @AppStorage(AppStorageKeys.childAvatar) private var storedAvatar = "lion.fill"

    @State private var childName = ""
    @State private var selectedAgeGroup = "4–6"
    @State private var selectedAvatar = "lion.fill"
    @State private var showNameError = false

    private let ageGroups = ["3–4", "4–6", "7–9", "10–12"]

    private let avatars = [
        "lion.fill",
        "hare.fill",
        "tortoise.fill",
        "bird.fill",
        "fish.fill",
        "pawprint.fill"
    ]

    var body: some View {
        GeometryReader { geo in
            let isPad = geo.size.width > 700
            let contentWidth = min(geo.size.width - 40, isPad ? 620 : geo.size.width - 40)

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

                        VStack(spacing: AppSpacing.large) {
                            avatarSection(isPad: isPad)
                            nameSection(isPad: isPad)
                            ageSection(isPad: isPad)
                            continueButton
                        }
                        .padding(isPad ? 30 : 20)
                        .background(AppColors.white.opacity(0.86))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
                        .shadow(color: AppColors.primary.opacity(0.12), radius: 22, x: 0, y: 12)
                        .frame(width: contentWidth)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, geo.safeAreaInsets.top + 24)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                }
            }
            .onAppear {
                childName = storedChildName
                selectedAgeGroup = storedAgeGroup.isEmpty ? "4–6" : storedAgeGroup
                selectedAvatar = storedAvatar
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool) -> some View {
        VStack(spacing: 10) {
            Text("Create Child Profile")
                .font(.system(size: isPad ? 42 : 31, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Personalize CurioKids for your little explorer.")
                .font(.system(size: isPad ? 19 : 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private func avatarSection(isPad: Bool) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.secondary.opacity(0.18))
                    .frame(width: isPad ? 130 : 104, height: isPad ? 130 : 104)

                Image(systemName: selectedAvatar)
                    .font(.system(size: isPad ? 58 : 46, weight: .bold))
                    .foregroundStyle(AppColors.primary)
            }

            Text("Choose Avatar")
                .font(.system(size: isPad ? 20 : 17, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                spacing: 12
            ) {
                ForEach(avatars, id: \.self) { avatar in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedAvatar = avatar
                        }
                    } label: {
                        Image(systemName: avatar)
                            .font(.system(size: isPad ? 34 : 28, weight: .bold))
                            .foregroundStyle(selectedAvatar == avatar ? .white : AppColors.primary)
                            .frame(height: isPad ? 72 : 60)
                            .frame(maxWidth: .infinity)
                            .background(selectedAvatar == avatar ? AppColors.primary : AppColors.primary.opacity(0.09))
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    }
                }
            }
        }
    }

    private func nameSection(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Child Name")
                .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            TextField("Enter name", text: $childName)
                .font(.system(size: isPad ? 20 : 17, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 18)
                .frame(height: isPad ? 62 : 56)
                .background(AppColors.backgroundBottom.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(showNameError ? AppColors.pink : Color.clear, lineWidth: 2)
                }

            if showNameError {
                Text("Please enter child name.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.pink)
            }
        }
    }

    private func ageSection(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Age Group")
                .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                spacing: 10
            ) {
                ForEach(ageGroups, id: \.self) { age in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            selectedAgeGroup = age
                        }
                    } label: {
                        Text(age)
                            .font(.system(size: isPad ? 18 : 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(selectedAgeGroup == age ? .white : AppColors.textPrimary)
                            .frame(height: isPad ? 58 : 52)
                            .frame(maxWidth: .infinity)
                            .background(selectedAgeGroup == age ? AppColors.accent : AppColors.accent.opacity(0.11))
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    }
                }
            }
        }
    }

    private var continueButton: some View {
        Button {
            let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedName.isEmpty else {
                withAnimation {
                    showNameError = true
                }
                return
            }

            storedChildName = trimmedName
            storedAgeGroup = selectedAgeGroup
            storedAvatar = selectedAvatar

            withAnimation(.easeInOut(duration: 0.35)) {
                onContinue()
            }
        } label: {
            HStack(spacing: 10) {
                Text("Continue")
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 17, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .shadow(color: AppColors.primary.opacity(0.22), radius: 16, x: 0, y: 9)
        }
        .padding(.top, 6)
    }
}

#Preview {
    ChildProfileSetupScreen {}
}
