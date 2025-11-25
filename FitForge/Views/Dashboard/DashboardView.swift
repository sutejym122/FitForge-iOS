//
//  DashboardView.swift.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//


//
//import SwiftUI
//
//struct DashboardView: View {
//    @State private var showMealPlan = false
//    @State private var mealPlanResponse: String = ""
//    @State private var isLoading = false
//    @State private var errorMessage = ""
//    
//    @EnvironmentObject var mealPlanStore: MealPlanStore
//    
//    @State private var profile: UserProfile? = nil
//    @State private var result: MetabolicResult? = nil
//
//    // MARK: - Init
//    init() { }
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                if let profile = profile, let result = result {
//                    dashboardContent(profile: profile, result: result)
//                } else {
//                    ProgressView("Loading your dashboard…")
//                        .onAppear { loadProfileAndMacros() }
//                }
//            }
//        }
//    }
//
//    // MARK: - Dashboard UI
//    private func dashboardContent(profile: UserProfile, result: MetabolicResult) -> some View {
//        ZStack {
//            ScrollView {
//                VStack(spacing: 25) {
//                    
//                    Text("Daily Targets")
//                        .font(.largeTitle.bold())
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top, 10)
//                    
//                    CalorieCard(result: result)
//                    
//                    Text("Macro Breakdown")
//                        .font(.title2.bold())
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    MacroChart(result: result)
//                        .frame(height: 250)
//                    
//                    // MARK: - Generate AI Meal Plan Button
//                    Button {
//                        generateMealPlan(profile: profile, result: result)
//                    } label: {
//                        if isLoading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        } else {
//                            Text("Generate AI Meal Plan")
//                                .font(.headline)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        }
//                    }
//                    .background(isLoading ? Color.gray : Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//                    .disabled(isLoading)
//                    .padding(.top, 10)
//                    
//                    if !errorMessage.isEmpty {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .font(.footnote)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                    
//                    Spacer()
//                }
//                .padding(.horizontal)
//            }
//            .blur(radius: isLoading ? 4 : 0)
//            .opacity(isLoading ? 0.4 : 1)
//            
//            if isLoading {
//                VStack {
//                    ProgressView("Generating your meal plan…")
//                        .padding()
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(12)
//                }
//                .transition(.opacity)
//            }
//        }
//        .navigationDestination(isPresented: $showMealPlan) {
//            MealPlanView(jsonText: mealPlanResponse)
//        }
//    }
//
//    // MARK: - Load Profile + Macros
//    private func loadProfileAndMacros() {
//        if let stored = ProfileStorage.shared.loadProfile() {
//            self.profile = stored
//            self.result = MetabolicCalculator.calculate(profile: stored)
//        }
//    }
//
//    // MARK: - Generate Meal Plan
//    private func generateMealPlan(profile: UserProfile, result: MetabolicResult) {
//        isLoading = true
//        errorMessage = ""
//        
//        let country = profile.country ?? (Locale.current.region?.identifier ?? "US")
//        
//        MealPlanService.generateMealPlan(
//            country: country,
//            goal: profile.goal,
//            calories: Int(result.goalCalories),
//            protein: Int(result.protein),
//            carbs: Int(result.carbs),
//            fats: Int(result.fats)
//        ) { response in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                guard let text = response else {
//                    self.errorMessage = "Failed to generate meal plan."
//                    return
//                }
//                
//                self.mealPlanResponse = text
//                
//                let saved = SavedMealPlan(
//                    id: UUID(),
//                    createdAt: Date(),
//                    title: "\(profile.goal) • \(Int(result.goalCalories)) kcal",
//                    goal: profile.goal,
//                    country: country,
//                    calories: Int(result.goalCalories),
//                    protein: Int(result.protein),
//                    carbs: Int(result.carbs),
//                    fats: Int(result.fats),
//                    rawJSON: text
//                )
//                
//                mealPlanStore.add(plan: saved)
//                self.showMealPlan = true
//            }
//        }
//    }
//}


//import SwiftUI
//
//struct DashboardView: View {
//
//    @EnvironmentObject var mealPlanStore: MealPlanStore
//
//    @State private var showMealPlan = false
//    @State private var mealPlanResponse: String = ""
//    @State private var isLoading = false
//    @State private var errorMessage = ""
//
//    // NEW: diet preference UI state
//    @State private var showDietSheet = false
//    @State private var selectedDietPreference: DietPreference = .mixed
//
//    // These are guaranteed to exist because ContentView checks them
//    private let profile: UserProfile = ProfileStorage.shared.currentProfile!
//    private let result: MetabolicResult
//
//    init() {
//        self.result = MetabolicCalculator.calculate(profile: ProfileStorage.shared.currentProfile!)
//    }
//
//    // Helper – resolve a nice country name
//    // Helper — resolve a nice country name
//    private var resolvedCountryName: String {
//        let c = profile.country.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if !c.isEmpty {
//            return c
//        }
//
//        if let code = Locale.current.region?.identifier {
//            return Locale.current.localizedString(forRegionCode: code) ?? code
//        }
//
//        return "United States"
//    }
//
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                ScrollView {
//                    VStack(spacing: 25) {
//
//                        Text("Daily Targets")
//                            .font(.largeTitle.bold())
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.top, 10)
//
//                        CalorieCard(result: result)
//
//                        Text("Macro Breakdown")
//                            .font(.title2.bold())
//                            .frame(maxWidth: .infinity, alignment: .leading)
//
//                        MacroChart(result: result)
//                            .frame(height: 250)
//
//                        // MARK: - Generate AI Meal Plan
//                        Button {
//                            // Instead of generating immediately, show diet preference selector
//                            showDietSheet = true
//                        } label: {
//                            if isLoading {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                            } else {
//                                Text("Generate AI Meal Plan")
//                                    .font(.headline)
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                            }
//                        }
//                        .background(isLoading ? Color.gray : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        .disabled(isLoading)
//                        .padding(.top, 10)
//
//                        if !errorMessage.isEmpty {
//                            Text(errorMessage)
//                                .foregroundColor(.red)
//                                .font(.footnote)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//                }
//                .blur(radius: isLoading ? 4 : 0)
//                .opacity(isLoading ? 0.4 : 1)
//
//                if isLoading {
//                    VStack {
//                        ProgressView("Generating your meal plan…")
//                            .padding()
//                            .background(.ultraThinMaterial)
//                            .cornerRadius(12)
//                    }
//                    .transition(.opacity)
//                }
//            }
//            .sheet(isPresented: $showDietSheet) {
//                DietPreferenceSheet(
//                    current: selectedDietPreference,
//                    country: resolvedCountryName
//                ) { choice in
//                    selectedDietPreference = choice
//                    showDietSheet = false
//                    // Trigger actual generation with chosen diet preference
//                    generateMealPlan(for: choice)
//                }
//            }
//            .navigationDestination(isPresented: $showMealPlan) {
//                MealPlanView(jsonText: mealPlanResponse)
//            }
//
//
//        }
//    }
//
//    // MARK: - MEAL PLAN LOGIC
//    private func generateMealPlan(for dietPreference: DietPreference) {
//        isLoading = true
//        errorMessage = ""
//
//        let country = resolvedCountryName
//        let caloriesInt = Int(result.goalCalories)
//        let proteinInt = Int(result.protein)
//        let carbsInt = Int(result.carbs)
//        let fatsInt = Int(result.fats)
//
//        // SAFETY: Don’t send invalid calories to backend
//        guard caloriesInt > 200 else {
//            errorMessage = "Profile data is invalid. Please update your stats in onboarding."
//            isLoading = false
//            return
//        }
//
//        MealPlanService.generateMealPlan(
//            country: country,
//            goal: profile.goal,
//            calories: caloriesInt,
//            protein: proteinInt,
//            carbs: carbsInt,
//            fats: fatsInt,
//            dietPreference: dietPreference.rawValue,
//            preferences: nil   // no extra text yet
//        ) { response in
//            DispatchQueue.main.async {
//                self.isLoading = false
//
//                guard let text = response else {
//                    self.errorMessage = "Failed to generate meal plan."
//                    return
//                }
//
//                self.mealPlanResponse = text
//
//                let title = "\(profile.goal) • \(caloriesInt) kcal"
//
//                let saved = SavedMealPlan(
//                    id: UUID(),
//                    createdAt: Date(),
//                    title: title,
//                    goal: profile.goal,
//                    country: country,
//                    calories: caloriesInt,
//                    protein: proteinInt,
//                    carbs: carbsInt,
//                    fats: fatsInt,
//                    rawJSON: text
//                )
//
//                mealPlanStore.add(plan: saved)
//                self.showMealPlan = true
//            }
//        }
//    }
//}
//
//// MARK: - Diet Preference Sheet
//
//struct DietPreferenceSheet: View {
//    let current: DietPreference
//    let country: String
//    let onSelect: (DietPreference) -> Void
//
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Text("Build Your Meal Plan")
//                    .font(.title2.bold())
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                Text("Please choose what you’re okay eating. Your plan will be based on your goal, your macros, and common foods in \(country).")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                VStack(spacing: 14) {
//                    ForEach(DietPreference.allCases) { pref in
//                        Button {
//                            onSelect(pref)
//                        } label: {
//                            HStack(alignment: .top, spacing: 10) {
//                                Image(systemName: pref == current ? "checkmark.circle.fill" : "circle")
//                                    .foregroundColor(.blue)
//                                    .font(.title3)
//
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(pref.displayName)
//                                        .font(.headline)
//                                    Text(pref.description)
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
//
//                                Spacer()
//                            }
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .cornerRadius(14)
//                        }
//                    }
//                }
//
//                Spacer()
//
//                Button(role: .cancel) {
//                    dismiss()
//                } label: {
//                    Text("Cancel")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//                .foregroundColor(.red.opacity(0.8))
//            }
//            .padding()
//            .navigationTitle("Diet Preference")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//


import SwiftUI

struct DashboardView: View {

    @EnvironmentObject var mealPlanStore: MealPlanStore

    @State private var showMealPlan = false
    @State private var mealPlanResponse: String = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    // NEW: Show profile screen
    @State private var showProfile = false

    // Diet preference UI state
    @State private var showDietSheet = false
    @State private var selectedDietPreference: DietPreference = .mixed

    // These are guaranteed to exist because ContentView checks them
    private let profile: UserProfile = ProfileStorage.shared.currentProfile!
    private let result: MetabolicResult

    init() {
        self.result = MetabolicCalculator.calculate(
            profile: ProfileStorage.shared.currentProfile!
        )
    }

    // Helper — resolve a nice country name
    private var resolvedCountryName: String {
        let trimmed = profile.country.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmed.isEmpty {
            return trimmed
        }

        if let code = Locale.current.region?.identifier {
            return Locale.current.localizedString(forRegionCode: code) ?? code
        }

        return "United States"
    }


    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 25) {

                        // MARK: - Daily Targets Header
                        Text("Daily Targets")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)

                        CalorieCard(result: result)

                        Text("Macro Breakdown")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        MacroChart(result: result)
                            .frame(height: 250)

                        // MARK: - Generate AI Meal Plan
                        Button {
                            showDietSheet = true
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Generate AI Meal Plan")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(isLoading)
                        .padding(.top, 10)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .blur(radius: isLoading ? 4 : 0)
                .opacity(isLoading ? 0.4 : 1)

                if isLoading {
                    VStack {
                        ProgressView("Generating your meal plan…")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                    .transition(.opacity)
                }
            }

            // Profile Sheet
            .sheet(isPresented: $showProfile) {
                UserProfileView(profile: ProfileStorage.shared.currentProfile!)
            }

            // Diet preference sheet
            .sheet(isPresented: $showDietSheet) {
                DietPreferenceSheet(
                    current: selectedDietPreference,
                    country: resolvedCountryName
                ) { choice in
                    selectedDietPreference = choice
                    showDietSheet = false
                    generateMealPlan(for: choice)
                }
            }

            // Navigate to full meal plan view
            .navigationDestination(isPresented: $showMealPlan) {
                MealPlanView(jsonText: mealPlanResponse)
            }

            // MARK: - Avatar Button on Top Right
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        if let data = profile.avatarImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                Text(profile.initials)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 36, height: 36)
                        }
                    }
                }
            }
        }
    }

    // MARK: - MEAL PLAN LOGIC
    private func generateMealPlan(for dietPreference: DietPreference) {
        isLoading = true
        errorMessage = ""

        let country = resolvedCountryName
        let caloriesInt = Int(result.goalCalories)
        let proteinInt = Int(result.protein)
        let carbsInt = Int(result.carbs)
        let fatsInt = Int(result.fats)

        guard caloriesInt > 200 else {
            errorMessage = "Profile data is invalid. Please update your stats in onboarding."
            isLoading = false
            return
        }

        MealPlanService.generateMealPlan(
            country: country,
            goal: profile.goal,
            calories: caloriesInt,
            protein: proteinInt,
            carbs: carbsInt,
            fats: fatsInt,
            dietPreference: dietPreference.rawValue,
            preferences: nil
        ) { response in
            DispatchQueue.main.async {
                self.isLoading = false

                guard let text = response else {
                    self.errorMessage = "Failed to generate meal plan."
                    return
                }

                self.mealPlanResponse = text

                let title = "\(profile.goal) • \(caloriesInt) kcal"

                let saved = SavedMealPlan(
                    id: UUID(),
                    createdAt: Date(),
                    title: title,
                    goal: profile.goal,
                    country: country,
                    calories: caloriesInt,
                    protein: proteinInt,
                    carbs: carbsInt,
                    fats: fatsInt,
                    rawJSON: text
                )

                mealPlanStore.add(plan: saved)
                self.showMealPlan = true
            }
        }
    }
}



