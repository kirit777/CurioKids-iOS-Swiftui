//
//  VoiceAnswerQuizScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import Speech
import AVFoundation
import Combine

struct VoiceAnswerQuizScreen: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var speechManager = SpeechQuizManager()

    @State private var currentIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var feedbackText = ""
    @State private var isCorrectAnswer = false

    private let questions = VoiceQuizQuestion.samples

    private var currentQuestion: VoiceQuizQuestion {
        questions[currentIndex]
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

                if showResult {
                    resultView(isPad: isPad)
                        .padding(.horizontal, isPad ? 40 : 20)
                        .frame(maxWidth: isPad ? 650 : .infinity)
                        .frame(maxWidth: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.large) {
                            headerView(isPad: isPad)

                            progressCard(isPad: isPad)

                            questionCard(isPad: isPad)

                            spokenAnswerCard(isPad: isPad)

                            micButton(isPad: isPad)

                            if !feedbackText.isEmpty {
                                feedbackCard(isPad: isPad)
                            }

                            nextButton
                        }
                        .padding(.horizontal, isPad ? 40 : 20)
                        //.padding(.top, geo.safeAreaInsets.top + 18)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                        .frame(maxWidth: isPad ? 700 : .infinity)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            speechManager.requestPermissions()
        }
        .onDisappear {
            speechManager.stopRecording()
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
                Text("Voice Quiz")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Speak your answer clearly.")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func progressCard(isPad: Bool) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(.system(size: isPad ? 17 : 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("Score: \(score)")
                    .font(.system(size: isPad ? 17 : 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primary)
            }

            ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                .tint(AppColors.primary)
        }
        .padding(isPad ? 20 : 16)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func questionCard(isPad: Bool) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(currentQuestion.color.opacity(0.16))
                    .frame(width: isPad ? 140 : 112, height: isPad ? 140 : 112)

                Image(systemName: currentQuestion.icon)
                    .font(.system(size: isPad ? 62 : 48, weight: .bold))
                    .foregroundStyle(currentQuestion.color)
            }

            Text(currentQuestion.question)
                .font(.system(size: isPad ? 28 : 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .padding(isPad ? 30 : 22)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
    }

    private func spokenAnswerCard(isPad: Bool) -> some View {
        VStack(spacing: 8) {
            Text("Your Answer")
                .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text(speechManager.transcript.isEmpty ? "Tap mic and speak..." : speechManager.transcript)
                .font(.system(size: isPad ? 22 : 18, weight: .semibold, design: .rounded))
                .foregroundStyle(speechManager.transcript.isEmpty ? AppColors.textSecondary : AppColors.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.white.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
    }

    private func micButton(isPad: Bool) -> some View {
        Button {
            if speechManager.isRecording {
                speechManager.stopRecording()
                checkAnswer()
            } else {
                feedbackText = ""
                speechManager.transcript = ""
                speechManager.startRecording()
            }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: isPad ? 38 : 30, weight: .bold))

                Text(speechManager.isRecording ? "Stop & Check" : "Speak Answer")
                    .font(.system(size: isPad ? 18 : 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(width: isPad ? 180 : 150, height: isPad ? 180 : 150)
            .background(speechManager.isRecording ? AppColors.pink : AppColors.primary)
            .clipShape(Circle())
            .shadow(color: AppColors.primary.opacity(0.22), radius: 18, x: 0, y: 10)
        }
        .disabled(!speechManager.hasPermission)
    }

    private func feedbackCard(isPad: Bool) -> some View {
        Text(feedbackText)
            .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
            .foregroundStyle(isCorrectAnswer ? AppColors.green : AppColors.pink)
            .multilineTextAlignment(.center)
            .padding(isPad ? 20 : 16)
            .frame(maxWidth: .infinity)
            .background((isCorrectAnswer ? AppColors.green : AppColors.pink).opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private var nextButton: some View {
        Button {
            goNext()
        } label: {
            HStack(spacing: 10) {
                Text(currentIndex == questions.count - 1 ? "See Result" : "Next Question")
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 17, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(feedbackText.isEmpty ? AppColors.textSecondary.opacity(0.35) : AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
        .disabled(feedbackText.isEmpty)
    }

    private func resultView(isPad: Bool) -> some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()

            Image(systemName: score >= 3 ? "star.fill" : "sparkles")
                .font(.system(size: isPad ? 86 : 68, weight: .bold))
                .foregroundStyle(AppColors.secondary)

            Text(score >= 3 ? "Amazing Speaking!" : "Good Try!")
                .font(.system(size: isPad ? 40 : 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Text("You scored \(score) out of \(questions.count)")
                .font(.system(size: isPad ? 20 : 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)

            Button {
                restart()
            } label: {
                Text("Play Again")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }

            Button {
                dismiss()
            } label: {
                Text("Back")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.white.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            }

            Spacer()
        }
    }

    private func checkAnswer() {
        let spoken = speechManager.transcript.lowercased()
        let correct = currentQuestion.answer.lowercased()

        if spoken.contains(correct) {
            score += 1
            isCorrectAnswer = true
            feedbackText = "Correct! Great speaking."
        } else {
            isCorrectAnswer = false
            feedbackText = "Nice try! Correct answer is \(currentQuestion.answer)."
        }
    }

    private func goNext() {
        if currentIndex == questions.count - 1 {
            showResult = true
        } else {
            currentIndex += 1
            speechManager.transcript = ""
            feedbackText = ""
            isCorrectAnswer = false
        }
    }

    private func restart() {
        currentIndex = 0
        score = 0
        showResult = false
        speechManager.transcript = ""
        feedbackText = ""
        isCorrectAnswer = false
    }
}

final class SpeechQuizManager: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var hasPermission = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.hasPermission = status == .authorized
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermission = self.hasPermission && granted
            }
        }
    }

    func startRecording() {
        stopRecording()

        request = SFSpeechAudioBufferRecognitionRequest()

        guard let request = request else { return }

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            return
        }

        let inputNode = audioEngine.inputNode
        request.shouldReportPartialResults = true

        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if error != nil {
                self.stopRecording()
            }
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            isRecording = false
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        request?.endAudio()
        task?.cancel()

        request = nil
        task = nil
        isRecording = false
    }
}

struct VoiceQuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let icon: String
    let color: Color

    static let samples: [VoiceQuizQuestion] = [
        .init(question: "Which animal is known as the king of the jungle?", answer: "Lion", icon: "pawprint.fill", color: AppColors.secondary),
        .init(question: "Which planet do we live on?", answer: "Earth", icon: "globe.asia.australia.fill", color: AppColors.accent),
        .init(question: "What do plants need to grow?", answer: "Sunlight", icon: "leaf.fill", color: AppColors.green),
        .init(question: "Which object gives us light during the day?", answer: "Sun", icon: "sun.max.fill", color: AppColors.secondary)
    ]
}

#Preview {
    NavigationStack {
        VoiceAnswerQuizScreen()
    }
}
