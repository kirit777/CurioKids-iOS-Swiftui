//
//  ReadAloudScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import AVFoundation
import Combine

struct ReadAloudScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = ReadAloudManager()

    @State private var selectedLesson = ReadAloudLesson.samples.first!
    @State private var speechRate: Float = 0.48

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

                        lessonPicker(isPad: isPad)

                        lessonCard(isPad: isPad)

                        speedCard(isPad: isPad)

                        controlButtons(isPad: isPad)
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
        .onDisappear {
            speechManager.stop()
        }
    }

    private func headerView(isPad: Bool) -> some View {
        HStack(spacing: 14) {
            Button {
                speechManager.stop()
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
                Text("Read Aloud")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Listen and learn with voice.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func lessonPicker(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Lesson")
                .font(.system(size: isPad ? 22 : 18, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ReadAloudLesson.samples) { lesson in
                        Button {
                            speechManager.stop()
                            selectedLesson = lesson
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: lesson.icon)
                                Text(lesson.title)
                            }
                            .font(.system(size: isPad ? 15 : 13, weight: .black, design: .rounded))
                            .foregroundStyle(selectedLesson.id == lesson.id ? .white : lesson.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(selectedLesson.id == lesson.id ? lesson.color : lesson.color.opacity(0.13))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(isPad ? 22 : 16)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }

    private func lessonCard(isPad: Bool) -> some View {
        VStack(spacing: 18) {
            Image(systemName: selectedLesson.icon)
                .font(.system(size: isPad ? 70 : 56, weight: .bold))
                .foregroundStyle(selectedLesson.color)
                .frame(width: isPad ? 120 : 96, height: isPad ? 120 : 96)
                .background(selectedLesson.color.opacity(0.14))
                .clipShape(Circle())

            Text(selectedLesson.title)
                .font(.system(size: isPad ? 30 : 24, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text(selectedLesson.text)
                .font(.system(size: isPad ? 18 : 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .padding(isPad ? 30 : 22)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: selectedLesson.color.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private func speedCard(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Voice Speed")
                    .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text(speedLabel)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.12))
                    .clipShape(Capsule())
            }

            Slider(value: $speechRate, in: 0.35...0.62)
                .tint(AppColors.primary)
                .onChange(of: speechRate) { _, _ in
                    if speechManager.isSpeaking {
                        speechManager.stop()
                        speechManager.speak(selectedLesson.text, rate: speechRate)
                    }
                }
        }
        .padding(isPad ? 22 : 16)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func controlButtons(isPad: Bool) -> some View {
        VStack(spacing: 12) {
            Button {
                if speechManager.isSpeaking {
                    speechManager.pause()
                } else if speechManager.isPaused {
                    speechManager.resume()
                } else {
                    speechManager.speak(selectedLesson.text, rate: speechRate)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: speechManager.mainButtonIcon)
                    Text(speechManager.mainButtonTitle)
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(selectedLesson.color)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }

            Button {
                speechManager.stop()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "stop.fill")
                    Text("Stop Reading")
                }
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.pink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(AppColors.pink.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }
        }
    }

    private var speedLabel: String {
        if speechRate < 0.42 { return "Slow" }
        if speechRate > 0.55 { return "Fast" }
        return "Normal"
    }
}

final class ReadAloudManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    @Published var isPaused = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    var mainButtonTitle: String {
        if isSpeaking { return "Pause Reading" }
        if isPaused { return "Resume Reading" }
        return "Start Reading"
    }

    var mainButtonIcon: String {
        if isSpeaking { return "pause.fill" }
        if isPaused { return "play.fill" }
        return "speaker.wave.2.fill"
    }

    func speak(_ text: String, rate: Float) {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.05
        utterance.volume = 1.0

        synthesizer.speak(utterance)

        isSpeaking = true
        isPaused = false
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
        isSpeaking = false
        isPaused = true
    }

    func resume() {
        synthesizer.continueSpeaking()
        isSpeaking = true
        isPaused = false
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.isPaused = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.isPaused = false
        }
    }
}

struct ReadAloudLesson: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let text: String

    static let samples: [ReadAloudLesson] = [
        .init(
            title: "Lion",
            icon: "pawprint.fill",
            color: AppColors.green,
            text: "A lion is a large wild cat. It is called the king of the jungle because it is strong and brave. Lions live in groups called prides."
        ),
        .init(
            title: "Earth",
            icon: "globe.asia.australia.fill",
            color: AppColors.accent,
            text: "Earth is our home planet. It has land, water, air, plants, animals, and people. Earth moves around the Sun once every year."
        ),
        .init(
            title: "Sun",
            icon: "sun.max.fill",
            color: AppColors.secondary,
            text: "The Sun is a star. It gives us light and heat. Plants use sunlight to make food and grow."
        ),
        .init(
            title: "Plants",
            icon: "leaf.fill",
            color: AppColors.green,
            text: "Plants are living things. They need sunlight, water, air, and soil to grow. Many plants give us fruits, flowers, and oxygen."
        )
    ]
}

#Preview {
    NavigationStack {
        ReadAloudScreen()
    }
}