//
//  ScanLearnOCRScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import Vision
import PhotosUI
import UIKit

struct ScanLearnOCRScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var recognizedText = ""
    @State private var simpleExplanation = ""
    @State private var isProcessing = false
    @State private var showCamera = false

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

                        actionCard(isPad: isPad)

                        if let selectedImage {
                            imagePreview(selectedImage, isPad: isPad)
                        }

                        if isProcessing {
                            ProgressView("Reading text...")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.textSecondary)
                                .padding()
                        }

                        if !recognizedText.isEmpty {
                            resultCard(
                                title: "Scanned Text",
                                text: recognizedText,
                                icon: "doc.text.fill",
                                color: AppColors.primary,
                                isPad: isPad
                            )
                        }

                        if !simpleExplanation.isEmpty {
                            resultCard(
                                title: "Simple Explanation",
                                text: simpleExplanation,
                                icon: "lightbulb.fill",
                                color: AppColors.secondary,
                                isPad: isPad
                            )
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
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $selectedImage) {
                processImage()
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            loadPhoto(newItem)
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
                Text("Scan & Learn")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Scan a page and make it easy to understand.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func actionCard(isPad: Bool) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "text.viewfinder")
                .font(.system(size: isPad ? 64 : 50, weight: .bold))
                .foregroundStyle(AppColors.primary)

            Text("Scan textbook, notes, or worksheet")
                .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button {
                    showCamera = true
                } label: {
                    actionButtonTitle("Camera", "camera.fill")
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    actionButtonTitle("Photos", "photo.fill")
                }
            }
        }
        .padding(isPad ? 28 : 22)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }

    private func actionButtonTitle(_ title: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 15, weight: .black, design: .rounded))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(AppColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func imagePreview(_ image: UIImage, isPad: Bool) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: isPad ? 360 : 260)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .shadow(color: AppColors.primary.opacity(0.12), radius: 14, x: 0, y: 8)
    }

    private func resultCard(title: String, text: String, icon: String, color: Color, isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Text(title)
                    .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }

            Text(text)
                .font(.system(size: isPad ? 17 : 14.5, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(5)
        }
        .padding(isPad ? 22 : 16)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }

            await MainActor.run {
                selectedImage = image
                processImage()
            }
        }
    }

    private func processImage() {
        guard let cgImage = selectedImage?.cgImage else { return }

        isProcessing = true
        recognizedText = ""
        simpleExplanation = ""

        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            DispatchQueue.main.async {
                recognizedText = text.isEmpty ? "No readable text found. Try a clearer image." : text
                simpleExplanation = makeSimpleExplanation(from: recognizedText)
                isProcessing = false
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            try? VNImageRequestHandler(cgImage: cgImage).perform([request])
        }
    }

    private func makeSimpleExplanation(from text: String) -> String {
        guard !text.isEmpty, !text.contains("No readable") else {
            return ""
        }

        let shortText = text
            .replacingOccurrences(of: "\n", with: " ")
            .prefix(350)

        return "This page is talking about: \(shortText). Try reading it slowly, then answer: what is the main idea?"
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let onImagePicked: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true) {
                self.parent.onImagePicked()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        ScanLearnOCRScreen()
    }
}
