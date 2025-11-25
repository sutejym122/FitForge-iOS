//
//  ContentView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//



import SwiftUI

struct ContentView: View {

    // Load profile once using ProfileStorage
    @State private var profile: UserProfile? = ProfileStorage.shared.loadProfile()
    @State private var macros: MetabolicResult? = nil

    var body: some View {
        Group {
            // CASE 1 — Profile + macros already loaded → show main app
            if let profile = profile, let macros = macros {
                mainAppView(profile: profile, macros: macros)

            // CASE 2 — Profile YES, macros NO → compute macros
            } else if let profile = profile, macros == nil {
                ProgressView("Loading your dashboard…")
                    .task {
                        macros = MetabolicCalculator.calculate(profile: profile)
                    }

            // CASE 3 — No profile → onboarding flow
            } else {
                OnboardingView { newProfile in
                    ProfileStorage.shared.saveProfile(newProfile)
                    profile = newProfile
                    macros = MetabolicCalculator.calculate(profile: newProfile)
                }
            }
        }
    }

    // MARK: - Tabs
    private func mainAppView(profile: UserProfile, macros: MetabolicResult) -> some View {
        TabView {
            
            DashboardView()
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Dashboard")
                }
            
            MyPlansView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("My Plans")
                }
            
            NavigationStack {
                ChatListView(profile: profile, macros: macros)
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Coach")
            }
        }
    }
}
