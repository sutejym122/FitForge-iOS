//
//  FitForgeWidgets.swift
//  FitForgeWidgets
//
//  Created by Sutej  Ym  on 12/8/25.
//

import WidgetKit
import SwiftUI

struct FitForgeEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> FitForgeEntry {
        FitForgeEntry(date: Date(), data: WidgetDataProvider.load())
    }

    func getSnapshot(in context: Context, completion: @escaping (FitForgeEntry) -> Void) {
        completion(FitForgeEntry(date: Date(), data: WidgetDataProvider.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FitForgeEntry>) -> Void) {

        let entry = FitForgeEntry(date: Date(), data: WidgetDataProvider.load())

        // Refresh every 15 minutes
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!

        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct FitForgeWidgetEntryView: View {
    let entry: FitForgeEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.7), .indigo.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 6) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))

                Text("🔥 \(entry.data.streak)d")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text(entry.data.weeklyInsight)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
            }
            .padding()
        }
    }
}

struct FitForgeWidget: Widget {
    let kind: String = "FitForgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FitForgeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FitForge Insights")
        .description("Shows your streak and weekly fitness insight.")
        .supportedFamilies([.systemSmall])
    }
}

struct FitForgeMediumWidget: Widget {
    let kind = "FitForgeMedium"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps: \(entry.data.stepsToday)")
                        .font(.headline).foregroundColor(.white)
                    Text("Water: \(String(format: "%.1fL", entry.data.hydrationToday))")
                        .font(.headline).foregroundColor(.white)
                    Text("Energy: \(Int(entry.data.activeEnergyToday)) kcal")
                        .font(.headline).foregroundColor(.white)
                }

                Divider().background(Color.white.opacity(0.3))

                Text(entry.data.weeklyInsight)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.subheadline)
                    .padding(.leading, 4)
            }
            .padding()
            .background(
                LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
        .configurationDisplayName("FitForge Weekly Insight")
        .description("Shows your activity metrics and AI summary.")
        .supportedFamilies([.systemMedium])
    }
}


