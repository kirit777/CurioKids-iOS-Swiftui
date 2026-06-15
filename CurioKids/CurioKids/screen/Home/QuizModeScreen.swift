//
//  QuizModeScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI

struct QuizModeScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var score = 0
    @State private var showResult = false
    @State private var isAnswered = false

    private let questions: [QuizQuestion] = [
        .init(
            question: "Which animal is known as the king of the jungle?",
            options: ["Tiger", "Lion", "Elephant", "Zebra"],
            correctAnswer: "Lion",
            icon: "pawprint.fill",
            color: AppColors.secondary
        ),
        .init(
            question: "Which planet do we live on?",
            options: ["Mars", "Venus", "Earth", "Jupiter"],
            correctAnswer: "Earth",
            icon: "globe.asia.australia.fill",
            color: AppColors.accent
        ),
        .init(
            question: "What do plants need to grow?",
            options: ["Sunlight", "Chocolate", "Plastic", "Shoes"],
            correctAnswer: "Sunlight",
            icon: "leaf.fill",
            color: AppColors.green
        ),
        .init(
            question: "Which object gives us light during the day?",
            options: ["Moon", "Sun", "Cloud", "Starfish"],
            correctAnswer: "Sun",
            icon: "sun.max.fill",
            color: AppColors.secondary
        )
    ]

    private var currentQuestion: QuizQuestion {
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
                            optionsList(isPad: isPad)
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
                    .background(AppColors.white.opacity(0.86))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Quiz Mode")
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Choose the correct answer")
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
                    .frame(width: isPad ? 130 : 105, height: isPad ? 130 : 105)

                Image(systemName: currentQuestion.icon)
                    .font(.system(size: isPad ? 58 : 46, weight: .bold))
                    .foregroundStyle(currentQuestion.color)
            }

            Text(currentQuestion.question)
                .font(.system(size: isPad ? 28 : 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .padding(isPad ? 28 : 22)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: currentQuestion.color.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private func optionsList(isPad: Bool) -> some View {
        VStack(spacing: 12) {
            ForEach(currentQuestion.options, id: \.self) { option in
                Button {
                    selectAnswer(option)
                } label: {
                    HStack(spacing: 12) {
                        Text(option)
                            .font(.system(size: isPad ? 20 : 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(optionTextColor(option))

                        Spacer()

                        if isAnswered {
                            if option == currentQuestion.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.green)
                            } else if option == selectedAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.pink)
                            }
                        }
                    }
                    .padding(isPad ? 20 : 16)
                    .background(optionBackground(option))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                            .stroke(optionBorder(option), lineWidth: 2)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isAnswered)
            }
        }
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
            .background(isAnswered ? AppColors.primary : AppColors.textSecondary.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
        .disabled(!isAnswered)
    }

    private func resultView(isPad: Bool) -> some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.secondary.opacity(0.18))
                    .frame(width: isPad ? 170 : 135, height: isPad ? 170 : 135)

                Image(systemName: score >= 3 ? "star.fill" : "sparkles")
                    .font(.system(size: isPad ? 78 : 60, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
            }

            VStack(spacing: 10) {
                Text(score >= 3 ? "Great Job!" : "Good Try!")
                    .font(.system(size: isPad ? 40 : 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("You scored \(score) out of \(questions.count)")
                    .font(.system(size: isPad ? 20 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Button {
                restartQuiz()
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

    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswered = true

        if answer == currentQuestion.correctAnswer {
            score += 1
        }
    }

    private func goNext() {
        if currentIndex == questions.count - 1 {
            showResult = true
        } else {
            currentIndex += 1
            selectedAnswer = nil
            isAnswered = false
        }
    }

    private func restartQuiz() {
        currentIndex = 0
        selectedAnswer = nil
        score = 0
        showResult = false
        isAnswered = false
    }

    private func optionBackground(_ option: String) -> Color {
        guard isAnswered else {
            return AppColors.white.opacity(0.88)
        }

        if option == currentQuestion.correctAnswer {
            return AppColors.green.opacity(0.14)
        }

        if option == selectedAnswer {
            return AppColors.pink.opacity(0.14)
        }

        return AppColors.white.opacity(0.88)
    }

    private func optionBorder(_ option: String) -> Color {
        guard isAnswered else {
            return Color.clear
        }

        if option == currentQuestion.correctAnswer {
            return AppColors.green
        }

        if option == selectedAnswer {
            return AppColors.pink
        }

        return Color.clear
    }

    private func optionTextColor(_ option: String) -> Color {
        if isAnswered && option == currentQuestion.correctAnswer {
            return AppColors.green
        }

        if isAnswered && option == selectedAnswer {
            return AppColors.pink
        }

        return AppColors.textPrimary
    }
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: String
    let icon: String
    let color: Color
}

#Preview {
    NavigationStack {
        QuizModeScreen()
    }
}
