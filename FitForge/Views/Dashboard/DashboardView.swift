//
//  DashboardView.swift.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
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

    // MARK: - Country Name Helper
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

    // MARK: - Greeting Title
    private var greetingText: String {
        let firstName = profile.name
            .split(separator: " ")
            .first
            .map(String.init) ?? "there"

        return "Hi, \(firstName)"
    }

    // MARK: - Professional Subtitle Based on Goal
    private var professionalGoalSubtitle: String {
        switch profile.goal.lowercased() {
        case "lose fat":
            return "Working towards fat-loss today."
        case "gain muscle":
            return "Working towards muscle-building today."
        case "maintain":
            return "Staying consistent today."
        default:
            return "Here’s your fitness summary for today."
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 25) {

                        // MARK: - Greeting Header
                        headerSection

                        // MARK: - Mini Progress Rings (Option D)
                        ProgressRingsRow()
                            .padding(.top, 4)
                            .padding(.bottom, 6)

                        // MARK: - Daily Targets Header
                        Text("Daily Targets")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        CalorieCard(result: result)

                        // MARK: - Macro Breakdown
                        Text("Macro Breakdown")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        MacroChart(result: result)
                            .frame(height: 250)

                        // MARK: - Activity (Placeholders)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 12) {
                                SummaryMiniCard(
                                    title: "Steps",
                                    value: "—",
                                    subtitle: "Connect Health later"
                                )

                                SummaryMiniCard(
                                    title: "Distance",
                                    value: "—",
                                    subtitle: "Coming soon"
                                )
                            }
                        }

                        // MARK: - Nutrition Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Nutrition")
                                .font(.title2.bold())

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

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
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

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greetingText)
                    .font(.title2.bold())
                Text(professionalGoalSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
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

// MARK: - Small Summary Card UI
private struct SummaryMiniCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
            Text(value)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

//
// MARK: - Progress Rings Row (Option D)
//
private struct ProgressRingsRow: View {
    var body: some View {
        HStack(spacing: 20) {

            ringItem(color: .red, title: "Move", value: "-- kcal")
            ringItem(color: .green, title: "Exercise", value: "-- min")
            ringItem(color: .blue, title: "Stand", value: "-- hrs")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func ringItem(color: Color, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 34, height: 34)

                Circle()
                    .trim(from: 0, to: 0.33)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 34, height: 34)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.primary.opacity(0.8))

            Text(value)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}






