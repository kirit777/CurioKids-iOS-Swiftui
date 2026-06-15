//
//  ColoringBookScreen.swift
//  CurioKids
//
//  Created by Kirit on 27/05/26.
//


import SwiftUI
import PencilKit

struct ColoringBookScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPage = ColoringPage.samples[0]
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showSavedMessage = false

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

                VStack(spacing: 16) {
                    headerView(isPad: isPad)

                    pageSelector(isPad: isPad)

                    coloringCanvas(isPad: isPad)

                    actionButtons(isPad: isPad)
                }
                .padding(.horizontal, isPad ? 40 : 18)
                .padding(.bottom, geo.safeAreaInsets.bottom + 20)
                .frame(maxWidth: isPad ? 850 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            loadDrawing()
        }
        .onChange(of: selectedPage.id) { _, _ in
            loadDrawing()
        }
    }

    private func headerView(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Button {
                saveDrawing()
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
                Text("Coloring Book")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Color characters and continue later.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func pageSelector(isPad: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ColoringPage.samples) { page in
                    Button {
                        saveDrawing()
                        selectedPage = page
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: page.icon)
                                .font(.system(size: 22, weight: .bold))

                            Text(page.title)
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundStyle(selectedPage.id == page.id ? .white : page.color)
                        .frame(width: isPad ? 90 : 76, height: isPad ? 74 : 66)
                        .background(selectedPage.id == page.id ? page.color : AppColors.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func coloringCanvas(isPad: Bool) -> some View {
        ZStack {
            AppColors.white.opacity(0.96)

            ColoringOutlineView(page: selectedPage)
                .padding(isPad ? 40 : 24)

            PencilCanvasView2(canvasView: $canvasView, toolPicker: $toolPicker)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        }
        .frame(maxWidth: .infinity)
        .frame(height: isPad ? 560 : 430)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: selectedPage.color.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private func actionButtons(isPad: Bool) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    saveDrawing()
                    showSavedMessage = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        showSavedMessage = false
                    }
                } label: {
                    Text("Save Coloring")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                }

                Button {
                    canvasView.drawing = PKDrawing()
                    saveDrawing()
                } label: {
                    Text("Clear")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.pink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(AppColors.pink.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                }
            }

            if showSavedMessage {
                Text("Saved! You can continue later.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.green)
            }
        }
    }

    private func saveDrawing() {
        let data = canvasView.drawing.dataRepresentation()
        UserDefaults.standard.set(data, forKey: storageKey(selectedPage.id))
    }

    private func loadDrawing() {
        if let data = UserDefaults.standard.data(forKey: storageKey(selectedPage.id)),
           let drawing = try? PKDrawing(data: data) {
            canvasView.drawing = drawing
        } else {
            canvasView.drawing = PKDrawing()
        }
    }

    private func storageKey(_ id: String) -> String {
        "coloring_page_\(id)"
    }
}

struct PencilCanvasView2: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct ColoringOutlineView: View {
    let page: ColoringPage

    var body: some View {
        ZStack {
            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.black.opacity(0.08))
                .padding(45)

            page.shape
                .stroke(.black.opacity(0.82), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                .padding(20)

            VStack {
                Spacer()

                Text(page.title)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
                    .padding(.bottom, 18)
            }
        }
        .allowsHitTesting(false)
    }
}

struct ColoringPage: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let shape: AnyShape

    static let samples: [ColoringPage] = [
        .init(id: "lion", title: "Lion", icon: "pawprint.fill", color: AppColors.secondary, shape: AnyShape(Circle())),
        .init(id: "cat", title: "Cat", icon: "cat.fill", color: AppColors.pink, shape: AnyShape(RoundedRectangle(cornerRadius: 60))),
        .init(id: "dog", title: "Dog", icon: "dog.fill", color: AppColors.green, shape: AnyShape(RoundedRectangle(cornerRadius: 45))),
        .init(id: "fish", title: "Fish", icon: "fish.fill", color: AppColors.accent, shape: AnyShape(Ellipse())),
        .init(id: "bird", title: "Bird", icon: "bird.fill", color: AppColors.primary, shape: AnyShape(Circle())),
        .init(id: "rabbit", title: "Rabbit", icon: "hare.fill", color: AppColors.green, shape: AnyShape(RoundedRectangle(cornerRadius: 80))),
        .init(id: "turtle", title: "Turtle", icon: "tortoise.fill", color: AppColors.accent, shape: AnyShape(Ellipse())),
        .init(id: "sun", title: "Sun", icon: "sun.max.fill", color: AppColors.secondary, shape: AnyShape(Circle())),
        .init(id: "moon", title: "Moon", icon: "moon.stars.fill", color: AppColors.primary, shape: AnyShape(Circle())),
        .init(id: "star", title: "Star", icon: "star.fill", color: AppColors.secondary, shape: AnyShape(Circle())),
        .init(id: "rocket", title: "Rocket", icon: "airplane.departure", color: AppColors.pink, shape: AnyShape(RoundedRectangle(cornerRadius: 70))),
        .init(id: "car", title: "Car", icon: "car.fill", color: AppColors.primary, shape: AnyShape(RoundedRectangle(cornerRadius: 30))),
        .init(id: "train", title: "Train", icon: "tram.fill", color: AppColors.accent, shape: AnyShape(RoundedRectangle(cornerRadius: 25))),
        .init(id: "house", title: "House", icon: "house.fill", color: AppColors.green, shape: AnyShape(RoundedRectangle(cornerRadius: 20))),
        .init(id: "tree", title: "Tree", icon: "tree.fill", color: AppColors.green, shape: AnyShape(RoundedRectangle(cornerRadius: 50))),
        .init(id: "flower", title: "Flower", icon: "camera.macro", color: AppColors.pink, shape: AnyShape(Circle())),
        .init(id: "apple", title: "Apple", icon: "apple.logo", color: AppColors.pink, shape: AnyShape(Circle())),
        .init(id: "ball", title: "Ball", icon: "basketball.fill", color: AppColors.secondary, shape: AnyShape(Circle())),
        .init(id: "gift", title: "Gift", icon: "gift.fill", color: AppColors.primary, shape: AnyShape(RoundedRectangle(cornerRadius: 20))),
        .init(id: "crown", title: "Crown", icon: "crown.fill", color: AppColors.secondary, shape: AnyShape(RoundedRectangle(cornerRadius: 35)))
    ]
}

struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        self.pathBuilder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

#Preview {
    NavigationStack {
        ColoringBookScreen()
    }
}
