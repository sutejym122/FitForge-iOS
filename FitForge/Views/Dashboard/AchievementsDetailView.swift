//
//  AchievementsDetailView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/27/25.
//

import SwiftUI

/// Full-screen achievements list.
/// Displays ALL achievement badges in a scrollable grid with category filters.
struct AchievementsDetailView: View {
    @ObservedObject var healthManager: HealthManager
    let result: MetabolicResult
    @ObservedObject var streakManager: StreakManager

    // MARK: - Category Filter
    enum Category: String, CaseIterable, Identifiable {
        case all = "All"
        case hydration = "Hydration"
        case steps = "Steps"
        case distance = "Distance"
        case sleep = "Sleep"
        case activity = "Activity"
        case streaks = "Streaks"
        case perfect = "Perfect Day"

        var id: String { self.rawValue }
    }

    @State private var selectedCategory: Category = .all

    // Pull the same badges from the main view
    private var allBadges: [AchievementsSectionView.AchievementBadge] {
        AchievementsSectionView(
            healthManager: healthManager,
            result: result,
            streakManager: streakManager
        ).badges
    }

    // MARK: - Category Filtering Logic
    private var filteredBadges: [AchievementsSectionView.AchievementBadge] {
        switch selectedCategory {
        case .all:
            return allBadges
        case .hydration:
            return allBadges.filter { $0.title.contains("Hydration") || $0.title.contains("Flood") }
        case .steps:
            return allBadges.filter { $0.title.contains("5K") || $0.title.contains("10K") || $0.title.contains("Step") }
        case .distance:
            return allBadges.filter { $0.title.contains("km") }
        case .sleep:
            return allBadges.filter { $0.title.contains("Sleep") || $0.title.contains("Recharge") || $0.title.contains("Recovered") }
        case .activity:
            return allBadges.filter { $0.title.contains("Move") }
        case .streaks:
            return allBadges.filter { $0.title.contains("Streak") || $0.title.contains("Week") || $0.title.contains("Warrior") || $0.title.contains("Flame") }
        case .perfect:
            return allBadges.filter { $0.title.contains("Perfect Day") }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack {

            // MARK: - Segmented Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(Category.allCases) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(filteredBadges) { badge in
                        AchievementBadgeCard(badge: badge)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }

        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: selectedCategory)
    }
}

