//
//  MealPlanService.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

//import Foundation
//
//class MealPlanService {
//    static func generateMealPlan(
//        country: String,
//        goal: String,
//        calories: Int,
//        protein: Int,
//        carbs: Int,
//        fats: Int,
//        dietPreference: String,
//        preferences: String?,
//        completion: @escaping (String?) -> Void
//    ) {
//        guard let url = URL(string: "http://127.0.0.1:5050/generate-mealplan") else {
//            completion(nil)
//            return
//        }
//
//        let body: [String: Any] = [
//            "country": country,
//            "goal": goal,
//            "calories": calories,
//            "protein": protein,
//            "carbs": carbs,
//            "fats": fats,
//            "diet_preference": dietPreference,
//            "preferences": preferences ?? ""
//        ]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
//        } catch {
//            print("❌ JSON Encoding Error:", error)
//            completion(nil)
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Network error:", error)
//                completion(nil)
//                return
//            }
//
//            guard let data = data else {
//                print("❌ No data received")
//                completion(nil)
//                return
//            }
//
//            let rawText = String(data: data, encoding: .utf8)
//            completion(rawText)
//
//        }.resume()
//    }
//}

import Foundation

class MealPlanService {
    static func generateMealPlan(
        country: String,
        goal: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fats: Int,
        dietPreference: String,
        preferences: String?,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "http://127.0.0.1:5050/generate-mealplan") else {
            completion(nil)
            return
        }

        let body: [String: Any] = [
            "country": country,
            "goal": goal,
            "calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fats": fats,
            "diet_preference": dietPreference,
            "preferences": preferences ?? ""
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ JSON Encoding Error:", error)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            let rawText = String(data: data, encoding: .utf8)
            completion(rawText)

        }.resume()
    }
}


