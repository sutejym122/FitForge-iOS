//
//  AIChatService.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//


import Foundation

final class AIChatService {

    /// Sends a full contextual chat request to the backend:
    /// - latest user message
    /// - profile (all fields)
    /// - macros
    /// - full chat history (user + assistant messages)
    static func sendMessageAdvanced(
        message: String,
        profile: UserProfile,
        macros: MetabolicResult,
        history: [ChatMessage],
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "http://127.0.0.1:5050/chat") else {
            print("❌ Invalid chat API URL")
            completion(nil)
            return
        }

        // 1️⃣ Convert history to backend format
        let mappedHistory: [[String: String]] = history.map { msg in
            [
                "role": msg.sender == .user ? "user" : "assistant",
                "content": msg.text
            ]
        }

        // 2️⃣ Profile dictionary
        let profileDict: [String: Any] = [
            "name": profile.name,
            "gender": profile.gender,
            "age": profile.age,
            "height": profile.height,
            "weight": profile.weight,
            "activityLevel": profile.activityLevel,
            "goal": profile.goal,
            "country": profile.country ?? "Unknown"
        ]

        // 3️⃣ Macros dictionary
        let macrosDict: [String: Any] = [
            "goalCalories": Int(macros.goalCalories),
            "protein": Int(macros.protein),
            "carbs": Int(macros.carbs),
            "fats": Int(macros.fats)
        ]

        // 4️⃣ Final POST body
        let body: [String: Any] = [
            "message": message,
            "profile": profileDict,
            "macros": macrosDict,
            "history": mappedHistory
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to encode JSON body:", error)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Chat network error:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ Chat: No data returned")
                completion(nil)
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("🔥 RAW BACKEND REPLY:\n\(raw)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let reply = json["reply"] as? String {
                    completion(reply)
                } else {
                    print("❌ Unexpected JSON reply")
                    completion(nil)
                }
            } catch {
                print("❌ JSON decode error:", error)
                completion(nil)
            }

        }.resume()
    }
}
