//
//  WeeklySummaryView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/28/25.
//

import SwiftUI
import Charts

struct WeeklySummaryView: View {
    @ObservedObject var healthManager: HealthManager

    // MARK: - Chart Data Model
    struct DailyData: Identifiable {
        let id = UUID()
        let day: String
        let value: Double
    }

    // MARK: - Generate last 7 days of data
    private var stepsData: [DailyData] {
        healthManager.stepsLast7Days.enumerated().map { index, value in
            DailyData(day: weekdayName(from: index), value: Double(value))
        }
    }

    private var hydrationData: [DailyData] {
        healthManager.hydrationLast7Days.enumerated().map { index, value in
            DailyData(day: weekdayName(from: index), value: value)
        }
    }

    private var sleepData: [DailyData] {
        healthManager.sleepLast7Days.enumerated().map { index, value in
            DailyData(day: weekdayName(from: index), value: value)
        }
    }

    // MARK: - Helpers

    private func weekdayName(from index: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        return symbols[(Calendar.current.component(.weekday, from: Date()) - 1 + index) % 7]
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("Weekly Summary")
                    .font(.largeTitle.bold())
                    .padding(.top)

                // MARK: - Steps Summary Chart
                summaryCard(title: "Steps This Week", average: stepsData.map{$0.value}.reduce(0,+) / 7) {
                    Chart(stepsData) {
                        BarMark(
                            x: .value("Day", $0.day),
                            y: .value("Steps", $0.value)
                        )
                    }
                    .frame(height: 160)
                }

                // MARK: - Hydration Summary Chart
                summaryCard(title: "Hydration Overview", average: hydrationData.map{$0.value}.reduce(0,+) / 7) {
                    Chart(hydrationData) {
                        LineMark(
                            x: .value("Day", $0.day),
                            y: .value("Liters", $0.value)
                        )
                        PointMark(
                            x: .value("Day", $0.day),
                            y: .value("Liters", $0.value)
                        )
                    }
                    .frame(height: 160)
                }

                // MARK: - Sleep Summary Chart
                summaryCard(title: "Sleep Analysis", average: sleepData.map{$0.value}.reduce(0,+) / 7) {
                    Chart(sleepData) {
                        AreaMark(
                            x: .value("Day", $0.day),
                            y: .value("Hours", $0.value)
                        )
                        .interpolationMethod(.cardinal)
                    }
                    .frame(height: 160)
                }

                // MARK: - Weekly Score
                weeklyScoreCard

                Spacer(minLength: 60)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Weekly Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Card Template
    private func summaryCard<Content: View>(title: String, average: Double, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            Text("Average: \(String(format: "%.1f", average))")
                .foregroundColor(.secondary)

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - FitForge Weekly Score
    private var weeklyScoreCard: some View {
        VStack(spacing: 12) {
            Text("FitForge Score")
                .font(.headline)

            Text("\(calculateScore()) / 100")
                .font(.system(size: 36, weight: .bold))

            Text(scoreDescription())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    private func calculateScore() -> Int {
        let stepsScore = min(Int((stepsData.map{$0.value}.reduce(0,+) / 7) / 100), 20)
        let hydrationScore = min(Int((hydrationData.map{$0.value}.reduce(0,+) / 7) * 5), 20)
        let sleepScore = min(Int((sleepData.map{$0.value}.reduce(0,+) / 7) * 3), 20)

        // Activity + streaks are placeholders for now
        let activityScore = 20
        let streakScore = 20

        return stepsScore + hydrationScore + sleepScore + activityScore + streakScore
    }

    private func scoreDescription() -> String {
        let score = calculateScore()

        switch score {
        case 90...100: return "Elite Week 🔥"
        case 70..<90: return "Strong Week 💪"
        case 50..<70: return "Healthy Week 👍"
        default: return "Room for Improvement 🌱"
        }
    }
}
