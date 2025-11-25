//
//  DietPreference.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/20/25.
//

import Foundation

/// High-level dietary preference used when generating meal plans.
enum DietPreference: String, CaseIterable, Identifiable, Codable {
    case veg
    case nonVeg = "non_veg"
    case mixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .veg:
            return "Only Veg"
        case .nonVeg:
            return "Only Non-Veg"
        case .mixed:
            return "Veg + Non-Veg"
        }
    }

    var description: String {
        switch self {
        case .veg:
            return "Meals built from lentils, beans, paneer/tofu, eggs, dairy, grains and vegetables."
        case .nonVeg:
            return "Chicken, fish, eggs and other lean meats with simple carbs and veggies."
        case .mixed:
            return "Balanced mix of vegetarian and non-vegetarian meals through the week."
        }
    }
}


