//
//  DayMeal.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import Foundation

struct DayMeal: Identifiable, Codable {
    var id = UUID()
    var day: Int
    var breakfast: String
    var lunch: String
    var dinner: String
    var snack: String
}
