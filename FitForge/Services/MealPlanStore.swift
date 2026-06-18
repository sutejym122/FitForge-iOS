//
//  MealPlanStore.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import Foundation
import Combine

private let savedMealPlansKey = "saved_meal_plans_v1"

final class MealPlanStore: ObservableObject {
    @Published private(set) var plans: [SavedMealPlan] = []
    
    init() {
        load()
    }
    
    // MARK: - Public API
    
    func add(plan: SavedMealPlan) {
            // Treat a plan as a duplicate when its goal, country, macro targets,
            // and diet preference all match an existing saved plan. We deliberately
            // ignore rawJSON: the AI returns slightly different text for identical
            // inputs, which made the previous exact-JSON rule never match.
            let isDuplicate = plans.contains { existing in
                existing.goal == plan.goal &&
                existing.country == plan.country &&
                existing.calories == plan.calories &&
                existing.protein == plan.protein &&
                existing.carbs == plan.carbs &&
                existing.fats == plan.fats &&
                existing.dietPreference == plan.dietPreference
            }

            guard !isDuplicate else { return }

            plans.insert(plan, at: 0) // newest on top
            persist()
        }
    
    func delete(at offsets: IndexSet) {
        plans.remove(atOffsets: offsets)
        persist()
    }
    
    // MARK: - Persistence
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: savedMealPlansKey) else {
            plans = []
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(SavedMealPlanList.self, from: data)
            self.plans = decoded.plans
        } catch {
            print("❌ Failed to decode saved meal plans:", error)
            self.plans = []
        }
    }
    
    private func persist() {
        do {
            let wrapper = SavedMealPlanList(plans: plans)
            let data = try JSONEncoder().encode(wrapper)
            UserDefaults.standard.set(data, forKey: savedMealPlansKey)
        } catch {
            print("❌ Failed to encode meal plans:", error)
        }
    }
}

