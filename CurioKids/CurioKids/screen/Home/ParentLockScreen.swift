import SwiftUI

struct ParentLockScreen: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.parentPIN) private var correctPin = "1234"

    @State private var pin = ""
    @State private var showError = false
    @State private var goToDashboard = false

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

                VStack(spacing: AppSpacing.large) {
                    headerView(isPad: isPad)

                    lockCard(isPad: isPad)

                    Spacer()
                }
                .padding(.horizontal, isPad ? 40 : 20)
                .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                .frame(maxWidth: isPad ? 620 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationDestination(isPresented: $goToDashboard) {
            ParentDashboardScreen()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func headerView(isPad: Bool) -> some View {
        HStack {
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

            Spacer()
        }
    }

    private func lockCard(isPad: Bool) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: isPad ? 76 : 60, weight: .bold))
                .foregroundStyle(AppColors.primary)

            VStack(spacing: 6) {
                Text("Parent Lock")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Enter parent PIN to open dashboard.")
                    .font(.system(size: isPad ? 16 : 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            SecureField("Enter 4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .background(AppColors.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                .onChange(of: pin) { _, newValue in
                    pin = String(newValue.prefix(4).filter { $0.isNumber })
                    showError = false
                }

            if showError {
                Text("Wrong PIN. Try again.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.pink)
            }

            Button {
                unlockDashboard()
            } label: {
                Text("Unlock Dashboard")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(pin.count == 4 ? AppColors.primary : AppColors.textSecondary.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
            .disabled(pin.count < 4)
        }
        .padding(isPad ? 30 : 22)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: AppColors.primary.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private func unlockDashboard() {
        if pin == correctPin {
            showError = false
            goToDashboard = true
        } else {
            showError = true
            pin = ""
        }
    }
}

#Preview {
    NavigationStack {
        ParentLockScreen()
    }
}
