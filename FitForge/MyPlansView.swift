//
//  MyPlansView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//


import SwiftUI

struct MyPlansView: View {
    @EnvironmentObject var mealPlanStore: MealPlanStore
    
    var body: some View {
        NavigationStack {
            Group {
                if mealPlanStore.plans.isEmpty {
                    EmptyPlansView()
                } else {
                    PlansListView(plans: mealPlanStore.plans)
                }
            }
            .navigationTitle("My Plans")
            .toolbar {
                if !mealPlanStore.plans.isEmpty {
                    EditButton()
                }
            }
        }
    }
}

//
// MARK: - EMPTY STATE VIEW
//
struct EmptyPlansView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No saved plans yet")
                .font(.headline)
            
            Text("Generate a meal plan from the Dashboard and it will be saved here automatically.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//
// MARK: - LIST VIEW WRAPPER
//
struct PlansListView: View {
    let plans: [SavedMealPlan]
    @EnvironmentObject var mealPlanStore: MealPlanStore
    
    var body: some View {
        List {
            ForEach(plans) { plan in
                NavigationLink(destination: MealPlanView(jsonText: plan.rawJSON)) {
                    PlanRow(plan: plan)
                        .padding(.vertical, 4)
                }
            }
            .onDelete(perform: mealPlanStore.delete)
        }
    }
}

//
// MARK: - PLAN ROW (Extracted for Compiler)
//
struct PlanRow: View {
    let plan: SavedMealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(plan.title)
                .font(.headline)
            
            Text("\(plan.goal) • \(plan.country)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Calories: \(plan.calories) • P: \(plan.protein)g • C: \(plan.carbs)g • F: \(plan.fats)g")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(plan.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}
