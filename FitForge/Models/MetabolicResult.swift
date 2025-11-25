//
//  MetabolicResult.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import Foundation

struct MetabolicResult: Identifiable {
    let id = UUID()
    
    let bmr: Double
    let tdee: Double
    let goalCalories: Double   // cutting or bulking
    let protein: Double
    let carbs: Double
    let fats: Double
}
