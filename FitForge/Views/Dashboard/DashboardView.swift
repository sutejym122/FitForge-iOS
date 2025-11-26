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
    
    @StateObject private var healthManager = HealthManager()

    init() {
        let currentProfile = ProfileStorage.shared.currentProfile!
        self.result = MetabolicCalculator.calculate(profile: currentProfile)
        _healthManager = StateObject(wrappedValue: HealthManager())
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

                        // MARK: - Weekly Progress Rings
                        ProgressRingsRow(healthManager: healthManager)
                            .padding(.top, 4)
                            .padding(.bottom, 6)

                        // MARK: - Daily Targets Header
                        Text("Daily Targets")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        CalorieCard(result: result, profile: profile)

                        // MARK: - Macro Breakdown
                        Text("Macro Breakdown")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // NEW: Macro Cards Row
                        MacroCardsRow(result: result)
                            .padding(.bottom, 4)

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

// MARK: - Macro Cards Row
private struct MacroCardsRow: View {
    let result: MetabolicResult

    private var totalGrams: Double {
        max(result.protein + result.carbs + result.fats, 1) // avoid divide-by-zero
    }

    var body: some View {
        HStack(spacing: 12) {
            MacroStatCard(
                title: "Protein",
                emoji: "🥩",
                grams: result.protein,
                color: .pink,
                totalGrams: totalGrams
            )
            MacroStatCard(
                title: "Carbs",
                emoji: "🍚",
                grams: result.carbs,
                color: .orange,
                totalGrams: totalGrams
            )
            MacroStatCard(
                title: "Fats",
                emoji: "🥑",
                grams: result.fats,
                color: .yellow,
                totalGrams: totalGrams
            )
        }
    }
}

// MARK: - Single Macro Stat Card
private struct MacroStatCard: View {
    let title: String
    let emoji: String
    let grams: Double
    let color: Color
    let totalGrams: Double

    private var percentageText: String {
        let pct = (grams / totalGrams) * 100
        return "\(Int(pct.rounded()))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack(spacing: 6) {
                Text(emoji)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }

            Text("\(Int(grams)) g")
                .font(.headline)
                .foregroundColor(.primary)

            Text(percentageText)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.12), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Ring Metric Model
private struct RingMetric: Identifiable {
    let id = UUID()
    let title: String
    let valueText: String
    let progress: Double   // 0...1
    let color: Color
}

// MARK: - Progress Rings Row (Weekly / Today Progress with HealthKit)
private struct ProgressRingsRow: View {

    @ObservedObject var healthManager: HealthManager

    private var metrics: [RingMetric] {
        let active = healthManager.activeEnergyToday
        let activeGoal = max(healthManager.activeEnergyGoal, 1)
        let activeProgress = min(active / activeGoal, 1.0)

        let steps = healthManager.stepsToday
        let stepsGoal = max(healthManager.stepsGoal, 1)
        let stepsProgress = min(steps / stepsGoal, 1.0)

        let water = healthManager.hydrationLitersToday
        let waterGoal = max(healthManager.hydrationGoalLiters, 0.1)
        let waterProgress = min(water / waterGoal, 1.0)

        let sleepTotal = healthManager.sleepTotalHours
        let sleepGoal: Double = 8.0
        let sleepProgress = min(sleepTotal / sleepGoal, 1.0)

        // Sleep style 3: show stage breakdown in compact form when data exists
        let deep = healthManager.sleepDeepHours
        let core = healthManager.sleepCoreHours
        let rem = healthManager.sleepRemHours

        let sleepValueText: String
        if sleepTotal > 0 {
            let tf = { (value: Double) -> String in
                String(format: "%.1f", value)
            }
            sleepValueText = "\(tf(sleepTotal))h  D\(tf(deep)) C\(tf(core)) R\(tf(rem))"
        } else {
            sleepValueText = "-- hrs"
        }

        return [
            RingMetric(
                title: "Calories",
                valueText: activeGoal > 0 ? "\(Int(active))/\(Int(activeGoal)) kcal" : "-- / --",
                progress: activeProgress,
                color: .red
            ),
            RingMetric(
                title: "Steps",
                valueText: stepsGoal > 0 ? "\(Int(steps))/\(Int(stepsGoal))" : "-- / --",
                progress: stepsProgress,
                color: .green
            ),
            RingMetric(
                title: "Hydration",
                valueText: waterGoal > 0 ? "\(String(format: "%.1f", water))/\(String(format: "%.1f", waterGoal)) L" : "-- / -- L",
                progress: waterProgress,
                color: .blue
            ),
            RingMetric(
                title: "Sleep",
                valueText: sleepValueText,
                progress: sleepProgress,
                color: .purple
            )
        ]
    }

    var body: some View {
        HStack(spacing: 14) {
            ForEach(metrics) { metric in
                VStack(spacing: 6) {

                    ProgressRing(
                        progress: metric.progress,
                        size: 52,
                        ringWidth: 6,
                        color: metric.color
                    )

                    Text(metric.title)
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.9))

                    Text(metric.valueText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Progress Ring View
private struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let ringWidth: CGFloat
    let color: Color

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: min(animatedProgress, 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}









