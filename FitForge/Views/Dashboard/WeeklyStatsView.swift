//
//  WeeklyStatsView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import SwiftUI
import Charts

struct WeeklyStatsView: View {

    @ObservedObject var healthManager: HealthManager
    @ObservedObject var workoutStore: WorkoutStore

    // MARK: - Data Models
    struct DayData: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }

    // MARK: - Helpers (Convert last 7 days arrays → chart data)
    private var stepsData: [DayData] {
        healthManager.stepsLast7Days.enumerated().map { idx, value in
            DayData(label: shortDayName(idx), value: Double(value))
        }
    }

    private var hydrationData: [DayData] {
        healthManager.hydrationLast7Days.enumerated().map { idx, value in
            DayData(label: shortDayName(idx), value: value)
        }
    }

    private var sleepData: [DayData] {
        healthManager.sleepLast7Days.enumerated().map { idx, value in
            DayData(label: shortDayName(idx), value: value)
        }
    }

    // MARK: - WEEKLY WORKOUT METRICS

    private var workoutsLast7Days: [WorkoutEntry] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return workoutStore.workouts.filter { $0.date >= weekAgo }
    }

    private var totalWorkoutCalories: Int {
        workoutsLast7Days.reduce(0) { $0 + $1.caloriesBurned }
    }

    private var totalWorkoutMinutes: Int {
        workoutsLast7Days.reduce(0) { $0 + $1.durationMinutes }
    }

    private var bestWorkout: WorkoutEntry? {
        workoutsLast7Days.max(by: { $0.caloriesBurned < $1.caloriesBurned })
    }

    // MARK: - Compute weekly totals
    private var totalSteps: Int {
        Int(healthManager.stepsLast7Days.reduce(0, +))
    }

    private var totalHydrationLiters: Double {
        healthManager.hydrationLast7Days.reduce(0, +)
    }

    private var totalSleepHours: Double {
        healthManager.sleepLast7Days.reduce(0, +)
    }

    // MARK: - Small helper
    private func shortDayName(_ index: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        return symbols[(Calendar.current.component(.weekday, from: Date()) - 1 + index) % 7]
    }

    // MARK: - View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // TITLE
                Text("Weekly Stats")
                    .font(.largeTitle.bold())
                    .padding(.top)

                // SUMMARY BOXES
                weeklyTotalsCard

                // WORKOUT SUMMARY
                workoutSummaryCard

                // INDIVIDUAL CHARTS
                stepsChart
                hydrationChart
                sleepChart

                // WEEKLY HIGHLIGHTS
                highlightsCard

                Spacer(minLength: 60)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Weekly Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - UI COMPONENTS

    private var weeklyTotalsCard: some View {
        VStack(spacing: 12) {
            Text("This Week at a Glance")
                .font(.headline)

            HStack(spacing: 16) {
                miniBox(title: "Steps", value: "\(totalSteps)")
                miniBox(title: "Hydration", value: "\(String(format: "%.1f", totalHydrationLiters)) L")
                miniBox(title: "Sleep", value: "\(String(format: "%.1f", totalSleepHours)) h")
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var workoutSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Summary")
                .font(.headline)

            if workoutsLast7Days.isEmpty {
                Text("No workouts logged this week.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                HStack {
                    miniBox(title: "Minutes", value: "\(totalWorkoutMinutes)")
                    miniBox(title: "Calories", value: "\(totalWorkoutCalories)")
                }

                if let best = bestWorkout {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Best Workout")
                            .font(.subheadline.bold())

                        Text("\(best.type) • \(best.durationMinutes) min • \(best.caloriesBurned) kcal")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Steps Chart
    private var stepsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Steps")
                .font(.headline)

            Chart(stepsData) {
                BarMark(
                    x: .value("Day", $0.label),
                    y: .value("Steps", $0.value)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 160)
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Hydration Chart
    private var hydrationChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Hydration (L)")
                .font(.headline)

            Chart(hydrationData) {
                LineMark(
                    x: .value("Day", $0.label),
                    y: .value("Liters", $0.value)
                )
                PointMark(
                    x: .value("Day", $0.label),
                    y: .value("Liters", $0.value)
                )
            }
            .frame(height: 160)
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Sleep Chart
    private var sleepChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Sleep (hrs)")
                .font(.headline)

            Chart(sleepData) {
                AreaMark(
                    x: .value("Day", $0.label),
                    y: .value("Hours", $0.value)
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 160)
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Highlights Card
    private var highlightsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Highlights")
                .font(.headline)

            Group {
                if totalSteps > 70000 {
                    Text("🏆 Incredible — You walked over 70k steps this week!")
                } else if totalSteps > 50000 {
                    Text("💪 Strong week — More than 50k steps!")
                }

                if totalHydrationLiters > 14 {
                    Text("💧 Hydration king — Avg > 2L/day!")
                }

                if totalSleepHours > 50 {
                    Text("😴 Great recovery — Avg > 7h/day.")
                }

                if workoutsLast7Days.count >= 4 {
                    Text("🔥 Nice consistency — \(workoutsLast7Days.count) workouts logged.")
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Helpers
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private func miniBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
    }
}
