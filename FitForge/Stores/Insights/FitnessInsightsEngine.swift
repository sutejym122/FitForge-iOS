//
//  FitnessInsightsEngine.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import Foundation

struct FitnessInsight: Identifiable {
    let id = UUID()
    let text: String
    let emoji: String
}

final class FitnessInsightsEngine {

    // MARK: - Generate Insights
    static func generateInsights(
        health: HealthManager,
        workouts: WorkoutStore
    ) -> [FitnessInsight] {

        var insights: [FitnessInsight] = []

        // ----- STEPS INSIGHTS -----
        let steps = health.stepsLast7Days
        if steps.count == 7 {
            let avg = steps.reduce(0,+) / 7
            if let maxDay = steps.max() {
                insights.append(
                    FitnessInsight(
                        text: "Your most active day had \(maxDay) steps — amazing consistency!",
                        emoji: "👣"
                    )
                )
            }

            if avg < 5000 {
                insights.append(
                    FitnessInsight(
                        text: "Your average steps are below 5k — a 10 min walk after meals can boost this easily.",
                        emoji: "⚠️"
                    )
                )
            }
        }

        // ----- HYDRATION INSIGHTS -----
        let water = health.hydrationLast7Days
        if water.count == 7 {
            let avg = water.reduce(0,+) / 7
            if avg >= health.hydrationGoalLiters * 0.8 {
                insights.append(
                    FitnessInsight(
                        text: "You're staying well hydrated this week — your recovery will thank you.",
                        emoji: "💧"
                    )
                )
            } else {
                insights.append(
                    FitnessInsight(
                        text: "Hydration was lower this week — try spacing your water intake every 2 hours.",
                        emoji: "🥤"
                    )
                )
            }
        }

        // ----- SLEEP INSIGHTS -----
        let sleep = health.sleepLast7Days
        if sleep.count == 7 {
            let avg = sleep.reduce(0,+) / 7
            if avg >= 7.5 {
                insights.append(
                    FitnessInsight(
                        text: "Your sleep has been strong — great for hormone balance and fat-loss.",
                        emoji: "😴"
                    )
                )
            } else {
                insights.append(
                    FitnessInsight(
                        text: "Sleep averaged below 7h — try reducing blue light 1 hour before bed.",
                        emoji: "🌙"
                    )
                )
            }
        }

        // ----- WORKOUT INSIGHTS -----
        let workoutsList = workouts.workouts
        if !workoutsList.isEmpty {
            let totalCalories = workoutsList.map { $0.caloriesBurned }.reduce(0,+)
            insights.append(
                FitnessInsight(
                    text: "You burned \(totalCalories) kcal through workouts this week — keep the momentum!",
                    emoji: "🔥"
                )
            )

            if workoutsList.count >= 3 {
                insights.append(
                    FitnessInsight(
                        text: "Great workout frequency — you trained \(workoutsList.count) times this week.",
                        emoji: "💪"
                    )
                )
            } else {
                insights.append(
                    FitnessInsight(
                        text: "Try aiming for 3 training sessions weekly — tiny changes, big results.",
                        emoji: "🏋️‍♂️"
                    )
                )
            }
        }

        // Fallback
        if insights.isEmpty {
            insights.append(
                FitnessInsight(
                    text: "Not enough data to generate insights yet — start logging workouts & enabling Health!",
                    emoji: "📊"
                )
            )
        }

        return insights
    }

    // MARK: - Recommendations
    static func generateRecommendations(health: HealthManager, workouts: WorkoutStore) -> [String] {
        var recs: [String] = []

        // Sleep recommendation
        if health.sleepLast7Days.reduce(0,+) / 7 < 7 {
            recs.append("Aim for 7–8 hours of sleep by keeping a fixed bedtime.")
        }

        // Steps recommendation
        if health.stepsLast7Days.reduce(0,+) / 7 < 6000 {
            recs.append("Try adding a 10-minute walk after meals.")
        }

        // Hydration
        if health.hydrationLast7Days.reduce(0,+) / 7 < health.hydrationGoalLiters * 0.8 {
            recs.append("Carry a bottle — sip small amounts every 30 minutes.")
        }

        if workouts.workouts.count < 3 {
            recs.append("Schedule 3 workout days in your calendar and treat them as meetings.")
        }

        if recs.isEmpty {
            recs.append("You're on track — keep doing what you're doing!")
        }

        return recs
    }
}
