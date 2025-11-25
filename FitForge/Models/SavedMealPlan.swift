//
//  SavedMealPlan.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import Foundation

struct SavedMealPlan: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    
    let title: String        // e.g. "Cutting • 2000 kcal"
    let goal: String         // e.g. "Cutting"
    let country: String      // e.g. "US"
    
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    
    let rawJSON: String      // full mealplan JSON from backend
}

struct SavedMealPlanList: Codable {
    var plans: [SavedMealPlan]
}
