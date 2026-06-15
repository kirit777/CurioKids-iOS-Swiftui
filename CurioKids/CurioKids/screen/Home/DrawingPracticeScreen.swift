//
//  DrawingPracticeScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import PencilKit

struct DrawingPracticeScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var canvasView = PKCanvasView()
    @State private var selectedPrompt = DrawingPrompt.samples[0]
    @State private var showClearAlert = false

    private let prompts = DrawingPrompt.samples

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

                VStack(spacing: 14) {
                    headerView(isPad: isPad, topInset: geo.safeAreaInsets.top)

                    promptSelector(isPad: isPad)

                    drawingArea(isPad: isPad)

                    bottomActions(bottomInset: geo.safeAreaInsets.bottom)
                }
                .padding(.horizontal, isPad ? 40 : 20)
                .frame(maxWidth: isPad ? 820 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .alert("Clear drawing?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                canvasView.drawing = PKDrawing()
            }
        } message: {
            Text("This will remove the current drawing.")
        }
    }

    private func headerView(isPad: Bool, topInset: CGFloat) -> some View {
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
                Text("Drawing Practice")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Trace, draw, and learn with fun shapes.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
       // .padding(.top, topInset + 18)
    }

    private func promptSelector(isPad: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(prompts) { prompt in
                    Button {
                        selectedPrompt = prompt
                        canvasView.drawing = PKDrawing()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: prompt.icon)
                            Text(prompt.title)
                        }
                        .font(.system(size: isPad ? 16 : 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(selectedPrompt.id == prompt.id ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(selectedPrompt.id == prompt.id ? prompt.color : AppColors.white.opacity(0.9))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func drawingArea(isPad: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                .fill(AppColors.white.opacity(0.95))
                .shadow(color: selectedPrompt.color.opacity(0.12), radius: 18, x: 0, y: 10)

            VStack(spacing: 10) {
                ZStack {
                    Text(selectedPrompt.traceText)
                        .font(.system(size: isPad ? 120 : 82, weight: .black, design: .rounded))
                        .foregroundStyle(selectedPrompt.color.opacity(0.16))
                        .minimumScaleFactor(0.5)

                    PencilCanvasView(canvasView: $canvasView)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                }

                Text(selectedPrompt.instruction)
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .padding(12)
        }
        .frame(maxHeight: .infinity)
        .frame(minHeight: isPad ? 520 : 430)
    }

    private func bottomActions(bottomInset: CGFloat) -> some View {
        HStack(spacing: 12) {
            Button {
                showClearAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Clear")
                }
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.pink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }

            Button {
                selectedPrompt = prompts.randomElement() ?? selectedPrompt
                canvasView.drawing = PKDrawing()
            } label: {
                HStack {
                    Image(systemName: "shuffle")
                    Text("New")
                }
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
        }
        .padding(.bottom, bottomInset + 14)
    }
}

struct PencilCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .systemIndigo, width: 8)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct DrawingPrompt: Identifiable {
    let id = UUID()
    let title: String
    let traceText: String
    let instruction: String
    let icon: String
    let color: Color

    static let samples: [DrawingPrompt] = [
        .init(title: "Letter A", traceText: "A", instruction: "Trace the big letter A.", icon: "textformat", color: AppColors.primary),
        .init(title: "Number 5", traceText: "5", instruction: "Trace the number 5 carefully.", icon: "number", color: AppColors.accent),
        .init(title: "Circle", traceText: "○", instruction: "Draw around the circle shape.", icon: "circle", color: AppColors.green),
        .init(title: "Star", traceText: "★", instruction: "Trace the star and decorate it.", icon: "star.fill", color: AppColors.secondary),
        .init(title: "Heart", traceText: "♥", instruction: "Trace the heart shape.", icon: "heart.fill", color: AppColors.pink)
    ]
}

#Preview {
    NavigationStack {
        DrawingPracticeScreen()
    }
}
