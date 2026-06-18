//
//  FitnessInsightsView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import SwiftUI
import AVFoundation

struct FitnessInsightsView: View {

    @ObservedObject var healthManager: HealthManager
    @ObservedObject var workoutStore: WorkoutStore

    @State private var animateCards = false
    @State private var synthesizer = AVSpeechSynthesizer()

    private var insights: [FitnessInsight] {
        FitnessInsightsEngine.generateInsights(
            health: healthManager,
            workouts: workoutStore
        )
    }

    private var recommendations: [String] {
        FitnessInsightsEngine.generateRecommendations(
            health: healthManager,
            workouts: workoutStore
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                headerSection

                insightCardSection

                recommendationSection

                Spacer(minLength: 80)
            }
            .padding(.horizontal)
        }
        .onAppear { animateCards = true }
        .navigationTitle("Weekly Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - HEADER
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("AI Insights")
                    .font(.largeTitle.bold())

                Text("Your personalized summary for this week.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: playVoiceSummary) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                    )
            }
            .accessibilityLabel("Play voice summary")
        }
        .padding(.top)
    }

    // MARK: - INSIGHT CARDS
    private var insightCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Your Week at a Glance")
                .font(.headline)

            ForEach(insights.indices, id: \.self) { i in
                let item = insights[i]

                HStack(alignment: .top, spacing: 16) {

                    Text(item.emoji)
                        .font(.system(size: 34))

                    Text(item.text)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(16)
                .background(gradientCard(i))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 20)
                .animation(
                    .easeOut(duration: 0.6).delay(Double(i) * 0.08),
                    value: animateCards
                )
            }
        }
    }

    // MARK: - RECOMMENDATIONS
    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Personal Recommendations")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {

                ForEach(recommendations.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.green.opacity(0.9))
                            .frame(width: 10, height: 10)

                        Text(recommendations[i])
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .opacity(animateCards ? 1 : 0)
                    .offset(y: animateCards ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.5).delay(0.5 + Double(i) * 0.08),
                        value: animateCards
                    )
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }

    // MARK: - GRADIENT CARD
    private func gradientCard(_ index: Int) -> LinearGradient {
        let colors = [
            [Color.blue, Color.indigo],
            [Color.purple, Color.blue],
            [Color.teal, Color.green],
            [Color.orange, Color.red],
            [Color.mint, Color.blue]
        ]

        let pick = colors[index % colors.count]

        return LinearGradient(
            colors: pick.map { $0.opacity(0.88) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: VOICE SUMMARY
    private func playVoiceSummary() {
        let combinedText = (
            "Here are your insights for this week. " +
            insights.map { $0.text }.joined(separator: ". ") +
            ". Recommendations: " +
            recommendations.joined(separator: ". ")
        )

        let utterance = AVSpeechUtterance(string: combinedText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
