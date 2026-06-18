//
//  StreakManager.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/26/25.
//

import Foundation
import Combine

struct DayStreak: Identifiable {
    let id = UUID()
    let date: Date
    let isOnTrack: Bool
}

final class StreakManager: ObservableObject {

    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var bestStreak: Int = 0
    @Published private(set) var recentDays: [DayStreak] = []

    private let storageKey = "ff_streak_log_v1"
    private var streakLog: [String: Bool] = [:]   // "yyyy-MM-dd" -> isOnTrack

    private let calendar = Calendar.current

    init() {
        load()
        rebuildDerivedState()
    }

    // MARK: - Public API

    func evaluateToday(isOnTrack: Bool) {
        let todayKey = key(for: Date())
        streakLog[todayKey] = isOnTrack
        save()
        rebuildDerivedState()
    }

    // MARK: - Storage

    private func save() {
        UserDefaults.standard.set(streakLog, forKey: storageKey)
    }

    private func load() {
        if let dict = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Bool] {
            streakLog = dict
        } else {
            streakLog = [:]
        }
    }

    // MARK: - Derived Values

    private func rebuildDerivedState() {
        currentStreak = calculateCurrentStreak()
        bestStreak = calculateBestStreak()
        recentDays = buildRecentDays()
    }

    private func calculateCurrentStreak() -> Int {
        var count = 0
        var day = Date()

        while true {
            let key = self.key(for: day)
            guard let onTrack = streakLog[key], onTrack == true else {
                break
            }
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previous
        }
        return count
    }

    private func calculateBestStreak() -> Int {
        // Walk all days in sorted order and compute max run of true values
        let keys = streakLog.keys.sorted()
        var maxStreak = 0
        var current = 0

        for key in keys {
            if streakLog[key] == true {
                current += 1
                maxStreak = max(maxStreak, current)
            } else {
                current = 0
            }
        }
        return maxStreak
    }

    private func buildRecentDays() -> [DayStreak] {
        var days: [DayStreak] = []
        for offset in (0..<7).reversed() {  // last 7 days, oldest -> newest
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let key = self.key(for: date)
            let isOnTrack = streakLog[key] ?? false
            days.append(DayStreak(date: date, isOnTrack: isOnTrack))
        }
        return days
    }

    // MARK: - Helpers

    private func key(for date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d",
                      comps.year ?? 0,
                      comps.month ?? 0,
                      comps.day ?? 0)
    }
}
