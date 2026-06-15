//
//  SplashScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct SplashScreen: View {
    let onFinish: () -> Void
    
    @State private var logoScale: CGFloat = 0.75
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 24
    @State private var floating = false
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let isPad = width > 700
            let logoSize = min(width * 0.34, isPad ? 190 : 145)
            
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.backgroundTop,
                        AppColors.backgroundBottom
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                decorativeBackground(width: width)
                
                VStack(spacing: AppSpacing.large) {
                    Spacer()
                    
                    Image("iconApp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.22, style: .continuous))
                        .opacity(logoOpacity)
                        .offset(y: floating ? -8 : 8)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: floating)
                    
                    VStack(spacing: AppSpacing.small) {
                        Text(AppConstants.appName)
                            .font(.system(size: isPad ? 54 : 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Text(AppConstants.appTagline)
                            .font(.system(size: isPad ? 22 : 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .offset(y: titleOffset)
                    .opacity(logoOpacity)
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        ProgressView()
                            .tint(AppColors.primary)
                        
                        Text("Preparing your learning world...")
                            .font(.system(size: isPad ? 17 : 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                }
                .padding(.horizontal, AppSpacing.large)
            }
            .onAppear {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        withAnimation(.spring(response: 0.75, dampingFraction: 0.72)) {
            logoScale = 1
            logoOpacity = 1
            titleOffset = 0
        }
        
        floating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onFinish()
        }
    }
    
    private func decorativeBackground(width: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(AppColors.primary.opacity(0.14))
                .frame(width: width * 0.42)
                .offset(x: -width * 0.42, y: -260)
            
            Circle()
                .fill(AppColors.secondary.opacity(0.18))
                .frame(width: width * 0.36)
                .offset(x: width * 0.42, y: -170)
            
            Circle()
                .fill(AppColors.pink.opacity(0.13))
                .frame(width: width * 0.32)
                .offset(x: width * 0.35, y: 250)
            
            Circle()
                .fill(AppColors.green.opacity(0.13))
                .frame(width: width * 0.28)
                .offset(x: -width * 0.38, y: 270)
            
            VStack {
                HStack {
                    floatingIcon("star.fill", color: AppColors.secondary)
                    Spacer()
                    floatingIcon("globe.asia.australia.fill", color: AppColors.accent)
                }
                
                Spacer()
                
                HStack {
                    floatingIcon("pawprint.fill", color: AppColors.green)
                    Spacer()
                    floatingIcon("moon.stars.fill", color: AppColors.pink)
                }
            }
            .padding(36)
        }
    }
    
    private func floatingIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(color.opacity(0.35))
    }
}

#Preview {
    SplashScreen {}
}
