import SwiftUI

struct ParentPINSetupScreen: View {
    let onFinish: () -> Void

    @AppStorage(AppStorageKeys.parentPIN) private var storedPIN = ""
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        GeometryReader { geo in
            let isPad = geo.size.width > 700
            let contentWidth = min(geo.size.width - 40, isPad ? 560 : geo.size.width - 40)

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
                            iconView(isPad: isPad)

                            pinField(
                                title: "Create Parent PIN",
                                placeholder: "4 digit PIN",
                                text: $pin,
                                isPad: isPad
                            )

                            pinField(
                                title: "Confirm PIN",
                                placeholder: "Re-enter PIN",
                                text: $confirmPin,
                                isPad: isPad
                            )

                            if showError {
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppColors.pink)
                                    .multilineTextAlignment(.center)
                            }

                            infoBox(isPad: isPad)

                            finishButton
                        }
                        .padding(isPad ? 30 : 20)
                        .background(AppColors.white.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
                        .shadow(color: AppColors.primary.opacity(0.12), radius: 22, x: 0, y: 12)
                        .frame(width: contentWidth)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, geo.safeAreaInsets.top + 24)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func headerView(isPad: Bool) -> some View {
        VStack(spacing: 10) {
            Text("Parent Safety PIN")
                .font(.system(size: isPad ? 42 : 31, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Protect parent controls, downloads, and learning settings.")
                .font(.system(size: isPad ? 19 : 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private func iconView(isPad: Bool) -> some View {
        ZStack {
            Circle()
                .fill(AppColors.green.opacity(0.16))
                .frame(width: isPad ? 132 : 108, height: isPad ? 132 : 108)

            Image(systemName: "lock.shield.fill")
                .font(.system(size: isPad ? 60 : 48, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.green, AppColors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private func pinField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isPad: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            SecureField(placeholder, text: text)
                .keyboardType(.numberPad)
                .font(.system(size: isPad ? 22 : 18, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, 18)
                .frame(height: isPad ? 62 : 56)
                .background(AppColors.backgroundBottom.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(showError ? AppColors.pink.opacity(0.8) : Color.clear, lineWidth: 2)
                }
                .onChange(of: text.wrappedValue) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }

                    if filtered.count > 4 {
                        text.wrappedValue = String(filtered.prefix(4))
                    } else {
                        text.wrappedValue = filtered
                    }

                    showError = false
                }
        }
    }

    private func infoBox(isPad: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColors.accent)

            Text("This PIN will be used for Parent Dashboard, screen time controls, and pack management.")
                .font(.system(size: isPad ? 16 : 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(3)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppColors.accent.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
    }

    private var finishButton: some View {
        Button {
            validateAndFinish()
        } label: {
            HStack(spacing: 10) {
                Text("Finish Setup")
                Image(systemName: "checkmark.circle.fill")
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

    private func validateAndFinish() {
        guard pin.count == 4 else {
            errorMessage = "Please enter a 4 digit PIN."
            showError = true
            return
        }

        guard confirmPin.count == 4 else {
            errorMessage = "Please confirm your 4 digit PIN."
            showError = true
            return
        }

        guard pin == confirmPin else {
            errorMessage = "PIN does not match. Please try again."
            showError = true
            return
        }

        storedPIN = pin
        hasCompletedOnboarding = true

        withAnimation(.easeInOut(duration: 0.35)) {
            onFinish()
        }
    }
}

#Preview {
    ParentPINSetupScreen {}
}
