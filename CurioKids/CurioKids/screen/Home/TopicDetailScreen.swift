//
//  TopicDetailScreen.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//


import SwiftUI
import AVFoundation

struct TopicDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    let topic: PackTopic
    let pack: LearningPack

    @State private var isSpeaking = false
    @State private var isCompleted = false

    private let speechSynthesizer = AVSpeechSynthesizer()

    private var lesson: TopicLesson {
        TopicLessonFactory.lesson(for: topic.title, packTitle: pack.title)
    }

    private var completionKey: String {
        "completed_\(pack.title)_\(topic.title)"
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.large) {
                        headerView(isPad: isPad)
                        heroCard(isPad: isPad)
                        lessonCard(isPad: isPad)
                        factsSection(isPad: isPad)
                        actionButtons(isPad: isPad)
                        completeButton
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
        .onAppear {
            isCompleted = UserDefaults.standard.bool(forKey: completionKey)
        }
        .onDisappear {
            stopSpeaking()
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
                    .background(AppColors.white.opacity(0.86))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.system(size: isPad ? 34 : 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(pack.title) Lesson")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
    }

    private func heroCard(isPad: Bool) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(topic.color.opacity(0.16))
                    .frame(width: isPad ? 180 : 140, height: isPad ? 180 : 140)

                Image(systemName: topic.icon)
                    .font(.system(size: isPad ? 82 : 64, weight: .bold))
                    .foregroundStyle(topic.color)

                Image(systemName: "sparkles")
                    .font(.system(size: isPad ? 30 : 24, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .offset(x: isPad ? 70 : 55, y: isPad ? -65 : -50)
            }

            VStack(spacing: 8) {
                Text(lesson.title)
                    .font(.system(size: isPad ? 30 : 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(lesson.shortLine)
                    .font(.system(size: isPad ? 18 : 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(isPad ? 30 : 22)
        .frame(maxWidth: .infinity)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous))
        .shadow(color: topic.color.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private func lessonCard(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Mini Lesson")
                    .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button {
                    toggleSpeech()
                } label: {
                    Image(systemName: isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(isSpeaking ? AppColors.pink : AppColors.accent)
                }
            }

            Text(lesson.description)
                .font(.system(size: isPad ? 18 : 15.5, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(5)
        }
        .padding(isPad ? 24 : 18)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private func factsSection(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Fun Facts")
                .font(.system(size: isPad ? 24 : 20, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(lesson.facts, id: \.self) { fact in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.secondary)
                        .padding(.top, 2)

                    Text(fact)
                        .font(.system(size: isPad ? 17 : 14.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineSpacing(4)

                    Spacer()
                }
                .padding(14)
                .background(AppColors.secondary.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            }
        }
    }

    private func actionButtons(isPad: Bool) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            NavigationLink {
                QuizModeScreen()
            } label: {
                lessonAction("Quiz", "questionmark.circle.fill", AppColors.pink, isPad: isPad)
            }
            .buttonStyle(.plain)

            NavigationLink {
                DrawingPracticeScreen()
            } label: {
                lessonAction("Draw", "pencil.and.scribble", AppColors.green, isPad: isPad)
            }
            .buttonStyle(.plain)
        }
    }

    private func lessonAction(_ title: String, _ icon: String, _ color: Color, isPad: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: isPad ? 24 : 20, weight: .bold))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: isPad ? 18 : 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()
        }
        .padding(isPad ? 20 : 16)
        .background(AppColors.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
    }

    private var completeButton: some View {
        Button {
            isCompleted.toggle()
            UserDefaults.standard.set(isCompleted, forKey: completionKey)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                Text(isCompleted ? "Lesson Completed" : "Mark as Completed")
            }
            .font(.system(size: 17, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(isCompleted ? AppColors.green : AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
    }

    private func toggleSpeech() {
        if isSpeaking {
            stopSpeaking()
        } else {
            let utterance = AVSpeechUtterance(string: "\(lesson.title). \(lesson.description). \(lesson.facts.joined(separator: ". "))")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.45
            speechSynthesizer.speak(utterance)
            isSpeaking = true
        }
    }

    private func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

struct TopicLesson {
    let title: String
    let shortLine: String
    let description: String
    let facts: [String]
}

enum TopicLessonFactory {
    static func lesson(for topic: String, packTitle: String) -> TopicLesson {
        switch topic {
        case "Lion":
            return TopicLesson(
                title: "Meet the Lion",
                shortLine: "A strong wild cat that lives in groups.",
                description: "Lions are powerful animals known for their golden fur and loud roar. They live in groups called prides. Lions mostly live in grasslands and hunt animals for food.",
                facts: [
                    "A lion’s roar can be heard from far away.",
                    "Female lions usually do most of the hunting.",
                    "Baby lions are called cubs."
                ]
            )

        case "Earth":
            return TopicLesson(
                title: "Our Planet Earth",
                shortLine: "The beautiful planet where we live.",
                description: "Earth is the third planet from the Sun. It has land, water, air, plants, animals, and people. Earth is special because it has the right conditions for life.",
                facts: [
                    "Most of Earth is covered with water.",
                    "Earth takes one year to go around the Sun.",
                    "Earth has one moon."
                ]
            )

        case "India":
            return TopicLesson(
                title: "Explore India",
                shortLine: "A country full of culture, colors, and history.",
                description: "India is a large country in Asia. It has many languages, festivals, foods, animals, rivers, and famous places. The capital city of India is New Delhi.",
                facts: [
                    "India has the Taj Mahal.",
                    "The national animal of India is the tiger.",
                    "India has many different languages."
                ]
            )

        default:
            return TopicLesson(
                title: "Learn About \(topic)",
                shortLine: "A simple lesson from the \(packTitle) pack.",
                description: "\(topic) is an interesting topic for children to explore. In this lesson, kids learn simple facts, listen to the lesson, and practice with quizzes and drawing.",
                facts: [
                    "\(topic) helps children build curiosity.",
                    "Learning with pictures makes topics easier to remember.",
                    "Quizzes help children revise what they learned."
                ]
            )
        }
    }
}

//#Preview {
//    NavigationStack {
//        TopicDetailScreen(
//            topic: PackTopic(
//                title: "Lion",
//                subtitle: "King of the jungle",
//                icon: "pawprint.fill",
//                color: AppColors.secondary,
//                isCompleted: false
//            ),
//            pack: LearningPack(
//                title: "Animals",
//                subtitle: "Wildlife, pets, birds, sea animals",
//                icon: "pawprint.fill",
//                color: AppColors.green,
//                lessonCount: 24,
//                isDownloaded: true,
//                progress: 0.35
//            )
//        )
//    }
//}
