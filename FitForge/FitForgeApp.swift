//
//  FitForgeApp.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/11/25.
//

//import SwiftUI
//
//@main
//struct FitForgeApp: App {
//    var body: some Scene {
//        WindowGroup {
//            OnboardingView()
//        }
//    }
//}

import SwiftUI

@main
struct FitForgeApp: App {
    @StateObject private var mealPlanStore = MealPlanStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mealPlanStore)
        }
    }
}
