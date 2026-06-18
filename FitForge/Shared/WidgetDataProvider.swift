//
//  WidgetDataProvider.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import Foundation

enum WidgetDataProvider {
    
    private static let storageKey = "fitforge.widget.data"

    static func save(_ data: WidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    static func load() -> WidgetData {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) {
            return decoded
        }

        // DEFAULT FALLBACK (when there's no data yet)
        return WidgetData(
            stepsToday: 0,
            hydrationToday: 0,
            activeEnergyToday: 0,
            streak: 0,
            weeklyInsight: "Welcome to FitForge"
        )
    }
}
