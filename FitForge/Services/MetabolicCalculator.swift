//
//  MetabolicCalculator.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import Foundation

struct MetabolicCalculator {
    
    static func calculate(profile: UserProfile) -> MetabolicResult {
        
        let weight = Double(profile.weight) ?? 0
        let height = Double(profile.height) ?? 0
        let age = Double(profile.age) ?? 0
        
        // Gender adjustment
        let genderFactor = profile.gender == "Male" ? 5 : -161
        
        // BMR (Mifflin-St Jeor)
        let bmr = (10 * weight) + (6.25 * height) - (5 * age) + Double(genderFactor)
        
        // Activity multiplier
        let activity: Double = {
            switch profile.activityLevel {
            case "Sedentary": return 1.2
            case "Active": return 1.55
            case "Very Active": return 1.725
            default: return 1.3
            }
        }()
        
        let tdee = bmr * activity
        
        // Goal handling
        let goalCalories: Double = {
            switch profile.goal {
            case "Lose Fat": return tdee - 400
            case "Gain Muscle": return tdee + 300
            default: return tdee
            }
        }()
        
        // Macro split
        let protein = weight * 2.2  // in grams
        let fats = (goalCalories * 0.25) / 9
        let carbs = (goalCalories - ((protein * 4) + (fats * 9))) / 4
        
        return MetabolicResult(
            bmr: bmr,
            tdee: tdee,
            goalCalories: goalCalories,
            protein: protein,
            carbs: carbs,
            fats: fats
        )
    }
}
