//
//  WorkoutEntry.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/3/25.
//

import Foundation

struct WorkoutEntry: Identifiable, Codable {
    let id: UUID
    var type: String
    var durationMinutes: Int
    var caloriesBurned: Int
    var date: Date

    init(
        id: UUID = UUID(),
        type: String,
        durationMinutes: Int,
        caloriesBurned: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.date = date
    }
}

