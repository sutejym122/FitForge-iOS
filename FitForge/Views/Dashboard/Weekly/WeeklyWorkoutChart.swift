//
//  WeeklyWorkoutChart.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import SwiftUI
import Charts

struct WeeklyWorkoutChart: View {

    @ObservedObject var workoutStore: WorkoutStore

    // MARK: - Derived Groupings

    /// Workouts grouped by day-of-week → [ "Mon": [WorkoutEntry] ]
    private var workoutsByDay: [String: [WorkoutEntry]] {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols

        var dict: [String: [WorkoutEntry]] = [:]
        for symbol in symbols { dict[symbol] = [] }

        for w in workoutStore.workouts {
            let dayIndex = calendar.component(.weekday, from: w.date) - 1
            let day = symbols[dayIndex]
            dict[day, default: []].append(w)
        }
        return dict
    }

    /// Daily total calories
    private var caloriesPerDay: [DailyValue] {
        workoutsByDay.map { (day, list) in
            DailyValue(day: day, value: list.reduce(0) { $0 + Double($1.caloriesBurned) })
        }
        .sorted { dayOrder($0.day) < dayOrder($1.day) }
    }

    /// Daily minutes trained
    private var minutesPerDay: [DailyValue] {
        workoutsByDay.map { (day, list) in
            DailyValue(day: day, value: list.reduce(0) { $0 + Double($1.durationMinutes) })
        }
        .sorted { dayOrder($0.day) < dayOrder($1.day) }
    }

    /// Workout type frequency (e.g., running = 3, push = 2)
    private var typeDistribution: [TypeSlice] {
        let groups = Dictionary(grouping: workoutStore.workouts, by: { $0.type })
        return groups.map { (type, list) in
            TypeSlice(type: type, count: list.count)
        }
    }

    // MARK: - Helpers

    private func dayOrder(_ day: String) -> Int {
        let symbols = Calendar.current.shortWeekdaySymbols
        return symbols.firstIndex(of: day) ?? 0
    }

    struct DailyValue: Identifiable {
        let id = UUID()
        let day: String
        let value: Double
    }

    struct TypeSlice: Identifiable {
        let id = UUID()
        let type: String
        let count: Int
    }

    private var totalCalories: Int {
        caloriesPerDay.map { Int($0.value) }.reduce(0, +)
    }

    private var totalMinutes: Int {
        minutesPerDay.map { Int($0.value) }.reduce(0, +)
    }

    private var bestWorkout: WorkoutEntry? {
        workoutStore.workouts.max(by: { $0.caloriesBurned < $1.caloriesBurned })
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("Workout Analytics")
                    .font(.largeTitle.bold())
                    .padding(.top)

                // MARK: - Summary Highlights
                summaryHighlights

                // MARK: - Calories Burned Chart
                chartCard(title: "Calories Burned (Daily)") {
                    Chart(caloriesPerDay) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Calories", item.value)
                        )
                        .foregroundStyle(.red.gradient)
                    }
                    .frame(height: 170)
                }

                // MARK: - Training Minutes Chart
                chartCard(title: "Training Minutes (Daily)") {
                    Chart(minutesPerDay) { item in
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.value)
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.value)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 170)
                }

                // MARK: - Workout Type Distribution
                chartCard(title: "Workout Type Distribution") {
                    Chart(typeDistribution) { slice in
                        SectorMark(
                            angle: .value("Count", slice.count),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .annotation(position: .overlay) {
                            Text(slice.type.prefix(6))
                                .font(.caption2)
                        }
                    }
                    .frame(height: 220)
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Workout Charts")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Cards
    private var summaryHighlights: some View {
        VStack(spacing: 12) {

            // Total calories + minutes
            HStack(spacing: 12) {
                smallStatCard(title: "Total Calories", value: "\(totalCalories)")
                smallStatCard(title: "Total Minutes", value: "\(totalMinutes)")
            }

            // Best workout
            if let best = bestWorkout {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best Workout")
                        .font(.headline)
                    Text("\(best.type) • \(best.caloriesBurned) kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                )
            }
        }
    }

    private func smallStatCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        )
    }

    // MARK: - Shared Chart Card Template
    private func chartCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}
