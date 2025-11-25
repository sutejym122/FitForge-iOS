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

