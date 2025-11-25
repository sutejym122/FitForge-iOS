//
//  ProfileStorage.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//


import Foundation

final class ProfileStorage {

    // MARK: - Singleton
    static let shared = ProfileStorage()

    private init() {}

    // MARK: - Storage Key
    private let PROFILE_KEY = "user_profile_v1"

    // MARK: - Save
    func saveProfile(_ profile: UserProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(data, forKey: PROFILE_KEY)
        } catch {
            print("❌ Failed to save profile:", error)
        }
    }

    // MARK: - Load
    func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: PROFILE_KEY) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("❌ Failed to load profile:", error)
            return nil
        }
    }

    // MARK: - Computed Accessor (Needed for DashboardView & ContentView)
    var currentProfile: UserProfile? {
        loadProfile()
    }

    // MARK: - Delete
    func clearProfile() {
        UserDefaults.standard.removeObject(forKey: PROFILE_KEY)
    }
}



