//
//  UserProfile.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import Foundation
import SwiftUI

struct UserProfile: Codable {
    var name: String
    /// Public handle shown as @username in the profile
    var username: String = ""

    var gender: String
    var age: String
    var height: String
    var weight: String
    var activityLevel: String
    var goal: String
    var country: String   // <-- NOT optional

    // MARK: - Optional avatar image (nil = use initials)
    var avatarImageData: Data? = nil

    // MARK: - Initials (used when there is no photo)
    var initials: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "FF" } // FitForge default

        let parts = trimmed.components(separatedBy: .whitespaces)
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""

        let combo = first + last
        return combo.isEmpty ? first : combo
    }

    // MARK: - Safe empty initializer for onboarding flow
    static var empty: UserProfile {
        UserProfile(
            name: "",
            username: "",
            gender: "Male",
            age: "",
            height: "",
            weight: "",
            activityLevel: "Sedentary",
            goal: "Maintain",
            country: Locale.current.region?.identifier ?? "United States",
            avatarImageData: nil
        )
    }
}



