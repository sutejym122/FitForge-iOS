//
//  AchievementsSectionView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/27/25.
//

import SwiftUI

/// Compact Achievements section shown on Dashboard.
/// Shows only top N achievements, with a button to open a full Achievements screen.
struct AchievementsSectionView: View {
    @ObservedObject var healthManager: HealthManager
    let result: MetabolicResult
    @ObservedObject var streakManager: StreakManager

    @State private var showAllAchievements = false
    @State private var recentlyUnlockedBadge: AchievementBadge?
    @State private var showUnlockPopup = false

    /// Number of badges to display on the dashboard
    private let maxDashboardBadges = 4

    // MARK: - Derived thresholds
    private var caloriesGoal: Double {
        max(result.goalCalories, 1)
    }

    private var stepsGoal: Double {
        max(healthManager.stepsGoal, 1)
    }

    private var hydrationGoal: Double {
        max(healthManager.hydrationGoalLiters, 0.1)
    }

    // MARK: - Unlock logic

    private var didHitHydrationGoal: Bool {
        healthManager.hydrationLitersToday >= hydrationGoal
    }

    private var didHitStepsGoal: Bool {
        healthManager.stepsToday >= stepsGoal
    }

    private var didHitMoveGoal: Bool {
        healthManager.activeEnergyToday >= caloriesGoal * 0.8
    }

    private var didPerfectDay: Bool {
        didHitHydrationGoal && didHitStepsGoal && didHitMoveGoal
    }

    // MARK: - Achievements model

    struct AchievementBadge: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let isUnlocked: Bool
        let accentColor: Color
    }

    // MARK: - Expanded Achievements Set

    var badges: [AchievementBadge] {

        let hydration = healthManager.hydrationLitersToday
        let steps = healthManager.stepsToday
        let distance = healthManager.distanceTodayKm
        let sleep = healthManager.sleepTotalHours
        let activeEnergy = healthManager.activeEnergyToday
        let currentStreak = streakManager.currentStreak
        let bestStreak = streakManager.bestStreak

        return [

            // MARK: - Hydration Tier
            AchievementBadge(
                title: "Hydration Rookie",
                subtitle: hydration >= 1.0 ? "Drank 1L of water 💧" : "Reach 1L today",
                icon: "drop.fill",
                isUnlocked: hydration >= 1.0,
                accentColor: .blue
            ),
            AchievementBadge(
                title: "Hydration Pro",
                subtitle: hydration >= 2.0 ? "2L in a day 💦" : "Drink 2L today",
                icon: "drop.fill",
                isUnlocked: hydration >= 2.0,
                accentColor: .blue.opacity(0.85)
            ),
            AchievementBadge(
                title: "Flood Season",
                subtitle: hydration >= 3.0 ? "3L champion 🌊" : "Hit 3L today",
                icon: "drop.fill",
                isUnlocked: hydration >= 3.0,
                accentColor: .cyan
            ),

            // MARK: - Step Milestones
            AchievementBadge(
                title: "5K Walker",
                subtitle: steps >= 5_000 ? "5,000+ steps 🚶‍♂️" : "Hit 5,000 steps",
                icon: "figure.walk.motion",
                isUnlocked: steps >= 5_000,
                accentColor: .green
            ),
            AchievementBadge(
                title: "10K Strider",
                subtitle: steps >= 10_000 ? "10k steps! 🏃‍♂️" : "Hit 10,000 steps",
                icon: "figure.walk.motion",
                isUnlocked: steps >= 10_000,
                accentColor: .green.opacity(0.85)
            ),
            AchievementBadge(
                title: "Step Demon",
                subtitle: steps >= 15_000 ? "15k+ steps 🔥" : "Walk 15,000 steps",
                icon: "flame.fill",
                isUnlocked: steps >= 15_000,
                accentColor: .orange
            ),

            // MARK: - Distance Milestones
            AchievementBadge(
                title: "3km Mover",
                subtitle: distance >= 3.0 ? "Moved 3 km 👟" : "Reach 3 km today",
                icon: "location.fill",
                isUnlocked: distance >= 3.0,
                accentColor: .purple
            ),
            AchievementBadge(
                title: "5km Club",
                subtitle: distance >= 5.0 ? "5 km badge 🎖️" : "Cover 5 km today",
                icon: "location.circle.fill",
                isUnlocked: distance >= 5.0,
                accentColor: .purple.opacity(0.8)
            ),
            AchievementBadge(
                title: "10km Endurance",
                subtitle: distance >= 10.0 ? "10 km beast 🏅" : "Hit 10 km",
                icon: "location.north.line.fill",
                isUnlocked: distance >= 10.0,
                accentColor: .indigo
            ),

            // MARK: - Sleep
            AchievementBadge(
                title: "Recovered",
                subtitle: sleep >= 7.0 ? "7 hrs of sleep 😴" : "Sleep 7 hrs",
                icon: "bed.double.fill",
                isUnlocked: sleep >= 7.0,
                accentColor: .mint
            ),
            AchievementBadge(
                title: "Deep Recharge",
                subtitle: sleep >= 8.0 ? "8+ hrs 🛌" : "Sleep 8 hrs",
                icon: "sparkles",
                isUnlocked: sleep >= 8.0,
                accentColor: .mint.opacity(0.8)
            ),

            // MARK: - Move Ring
            AchievementBadge(
                title: "Move Ring",
                subtitle: activeEnergy >= caloriesGoal ? "Calorie goal done 🔥" : "Hit your move goal",
                icon: "flame.fill",
                isUnlocked: activeEnergy >= caloriesGoal,
                accentColor: .red
            ),

            // MARK: - Perfect Day
            AchievementBadge(
                title: "Perfect Day",
                subtitle: didPerfectDay ? "All goals smashed ⚡️" : "Hit all daily goals",
                icon: "star.fill",
                isUnlocked: didPerfectDay,
                accentColor: .yellow
            ),

            // MARK: - Streaks
            AchievementBadge(
                title: "3-Day Flame",
                subtitle: currentStreak >= 3 ? "3 perfect days 🔥" : "Stay perfect for 3 days",
                icon: "flame.fill",
                isUnlocked: currentStreak >= 3,
                accentColor: .orange
            ),
            AchievementBadge(
                title: "Perfect Week",
                subtitle: currentStreak >= 7 ? "7 perfect days 📅" : "Perfect for a week",
                icon: "calendar",
                isUnlocked: currentStreak >= 7,
                accentColor: .blue
            ),
            AchievementBadge(
                title: "Two-Week Warrior",
                subtitle: currentStreak >= 14 ? "14 perfect days ⚔️" : "Perfect for 14 days",
                icon: "shield.fill",
                isUnlocked: currentStreak >= 14,
                accentColor: .teal
            ),
            AchievementBadge(
                title: "Unbreakable",
                subtitle: bestStreak >= 30 ? "30-day best streak 🏆" : "Reach a 30-day best streak",
                icon: "crown.fill",
                isUnlocked: bestStreak >= 30,
                accentColor: .yellow
            )
        ]
    }

    // MARK: - Detect newly unlocked badges

    private func detectNewUnlocks() {
        for badge in badges {
            let key = "badge_unlocked_\(badge.title)"

            if badge.isUnlocked {
                let wasUnlockedBefore = UserDefaults.standard.bool(forKey: key)

                if !wasUnlockedBefore {
                    recentlyUnlockedBadge = badge
                    showUnlockPopup = true

                    UserDefaults.standard.set(true, forKey: key)
                    break
                }
            }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Achievements")
                    .font(.title3.bold())
                Spacer()
                Text("Today")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)

            // MARK: - Compact grid (first 4)
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(badges.prefix(maxDashboardBadges)) { badge in
                    AchievementBadgeCard(badge: badge)
                }
            }

            // MARK: - Button: Show All Achievements
            Button(action: {
                showAllAchievements = true
            }) {
                HStack {
                    Text("Show All Achievements")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.bold())
                .foregroundColor(.accentColor)
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
            .navigationDestination(isPresented: $showAllAchievements) {
                AchievementsDetailView(
                    healthManager: healthManager,
                    result: result,
                    streakManager: streakManager
                )
            }
        }
        .padding(.top, 4)
        .onAppear {
            detectNewUnlocks()
        }
        .overlay(
            Group {
                if showUnlockPopup, let badge = recentlyUnlockedBadge {
                    BadgeUnlockPopup(badge: badge) {
                        showUnlockPopup = false
                    }
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
                }
            }
        )
    }
}

// MARK: - Badge Card UI

struct AchievementBadgeCard: View {
    let badge: AchievementsSectionView.AchievementBadge

    var body: some View {
        let isUnlocked = badge.isUnlocked

        HStack(alignment: .top, spacing: 10) {

            ZStack {
                Circle()
                    .fill(badge.accentColor.opacity(isUnlocked ? 0.20 : 0.08))
                    .frame(width: 32, height: 32)

                Image(systemName: isUnlocked ? badge.icon : "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isUnlocked ? badge.accentColor : .secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(badge.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary.opacity(isUnlocked ? 1.0 : 0.7))

                Text(badge.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(isUnlocked ? 0.08 : 0.03),
                    radius: isUnlocked ? 8 : 4,
                    x: 0,
                    y: 3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    badge.accentColor.opacity(isUnlocked ? 0.35 : 0.12),
                    lineWidth: 1
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.65)
        .scaleEffect(isUnlocked ? 1.0 : 0.98)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: badge.isUnlocked)
    }
}






