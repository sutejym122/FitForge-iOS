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
    
    @StateObject var streakManager = StreakManager()
    
    @State private var showWeeklySummary = false
    @State private var showWeeklyStats = false
    @State private var showWorkoutCharts = false
    @State private var showInsights = false



    
    @StateObject var workoutStore = WorkoutStore()


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
            return "Here's your fitness summary for today."
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 25) {

                        // MARK: - Greeting Header
                        headerSection
                        
                        // MARK: - Daily Brief (NEW)
                        dailyBriefCard

                        // MARK: - Weekly Progress Rings
                        ProgressRingsRow(healthManager: healthManager)
                            .padding(.top, 4)
                            .padding(.bottom, 6)

                        // MARK: - Hydration Quick Add
                        HydrationQuickAddView(healthManager: healthManager)
                            .padding(.bottom, 4)

                        // MARK: - Steps & Distance Section
                        StepsDistanceSection(healthManager: healthManager)
                            .padding(.top, 4)

                        // MARK: - Streaks Row (NEW)
                        StreaksRowView(healthManager: healthManager)
                            .padding(.top, 2)
                        
                        // MARK: - Achievements Section
                        AchievementsSectionView(
                            healthManager: healthManager,
                            result: result,
                            streakManager: streakManager
                        )
                        .padding(.top, 4)
                        
                        Button(action: {
                            showWeeklySummary = true
                        }) {
                            HStack {
                                Text("View Weekly Summary")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                            )
                        }
                        .navigationDestination(isPresented: $showWeeklySummary) {
                            WeeklySummaryView(healthManager: healthManager)
                        }


                        WorkoutsSectionView(workoutStore: workoutStore)
                            .padding(.top, 8)
                        
                        Button {
                            showWeeklyStats = true
                        } label: {
                            HStack {
                                Text("View Detailed Stats")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                            )
                        }
                        .navigationDestination(isPresented: $showWeeklyStats) {
                            WeeklyStatsView(healthManager: healthManager, workoutStore: workoutStore)
                        }
                        
                        Button(action: { showWorkoutCharts = true }) {
                            HStack {
                                Text("Workout Analytics")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 6)
                            )
                        }
                        .navigationDestination(isPresented: $showWorkoutCharts) {
                            WeeklyWorkoutChart(workoutStore: workoutStore)
                        }
                        
                        Button {
                            showInsights = true
                        } label: {
                            HStack {
                                Text("AI Insights")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 6)
                            )
                        }
                        .navigationDestination(isPresented: $showInsights) {
                            FitnessInsightsView(
                                healthManager: healthManager,
                                workoutStore: workoutStore
                            )
                        }




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
            
            .onAppear { saveWidgetSnapshot() }
                        .onChange(of: healthManager.stepsToday) { _, _ in saveWidgetSnapshot() }
                        .onChange(of: healthManager.hydrationLitersToday) { _, _ in saveWidgetSnapshot() }
                        .onChange(of: healthManager.activeEnergyToday) { _, _ in saveWidgetSnapshot() }

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
    
    // MARK: - Daily Brief
        private var dailyBrief: DailyBrief {
            DailyBriefBuilder.make(
                goal: profile.goal,
                goalCalories: Int(result.goalCalories),
                healthAuthorized: healthManager.isAuthorized,
                waterLiters: healthManager.hydrationLitersToday,
                waterGoalLiters: healthManager.hydrationGoalLiters,
                sleepHours: healthManager.sleepTotalHours,
                hasAnyPlan: !mealPlanStore.plans.isEmpty
            )
        }

        private var dailyBriefCard: some View {
            let brief = dailyBrief
            return VStack(alignment: .leading, spacing: 10) {
                Text("TODAY")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)

                Text(brief.headline)
                    .font(.title3.bold())
                    .fixedSize(horizontal: false, vertical: true)

                Text(brief.reason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    performBriefAction(brief.action)
                } label: {
                    Text(brief.ctaTitle)
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }

        private func performBriefAction(_ action: DailyBrief.CTAAction) {
            switch action {
            case .generateMealPlan:
                showDietSheet = true
            case .openMealPlan:
                if let latest = mealPlanStore.plans.first {
                    mealPlanResponse = latest.rawJSON
                    showMealPlan = true
                } else {
                    showDietSheet = true
                }
            case .addWater:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                healthManager.addManualWater(amountLiters: 0.5)
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
                    dietPreference: dietPreference.rawValue,
                    rawJSON: text
                )

                mealPlanStore.add(plan: saved)
                self.showMealPlan = true
            }
        }
    }
    private func saveWidgetSnapshot() {
            let insights = FitnessInsightsEngine.generateInsights(
                health: healthManager,
                workouts: workoutStore
            )

            let firstInsight = insights.first?.text ?? "Stay active today!"

            let data = WidgetData(
                stepsToday: Int(healthManager.stepsToday),
                hydrationToday: healthManager.hydrationLitersToday,
                activeEnergyToday: healthManager.activeEnergyToday,
                streak: streakManager.currentStreak,
                weeklyInsight: firstInsight
            )

            WidgetDataProvider.save(data)
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

// MARK: - Hydration Quick Add UI
private struct HydrationQuickAddView: View {
    @ObservedObject var healthManager: HealthManager

    @State private var showCustomInput = false
    @State private var customAmount = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Hydration")
                .font(.title3.bold())
                .padding(.leading, 4)

            HStack(spacing: 12) {

                quickButton(amount: 0.25, label: "+250ml", color: .blue)
                quickButton(amount: 0.5, label: "+500ml", color: .teal)
                quickButton(amount: 1.0, label: "+1L", color: .indigo)

                Button {
                    showCustomInput = true
                } label: {
                    Text("Custom")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $showCustomInput) {
            customHydrationSheet
        }
    }

    // MARK: - Quick Add Button
    private func quickButton(amount: Double, label: String, color: Color) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            healthManager.addManualWater(amountLiters: amount)
        } label: {
            Text(label)
                .font(.subheadline.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(12)
        }
    }

    // MARK: - Custom Hydration Sheet
    private var customHydrationSheet: some View {
        NavigationStack {
            Form {
                Section("Enter amount (ml)") {
                    TextField("e.g. 330", text: $customAmount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Custom Water")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showCustomInput = false
                        customAmount = ""
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addCustomWater()
                    }
                    .disabled(customAmount.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addCustomWater() {
        guard let ml = Double(customAmount), ml > 0 else { return }

        let liters = ml / 1000.0
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        healthManager.addManualWater(amountLiters: liters)

        showCustomInput = false
        customAmount = ""
    }
}

// MARK: - Steps & Distance Section
private struct StepsDistanceSection: View {
    @ObservedObject var healthManager: HealthManager

    var body: some View {
        VStack(spacing: 14) {
            // Title
            HStack {
                Text("Activity Overview")
                    .font(.title3.bold())
                Spacer()
            }
            // Card
            VStack(spacing: 14) {
                HStack {
                    Label("Steps", systemImage: "figure.walk")
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.8))
                    Spacer()
                    Text("\(Int(healthManager.stepsToday))")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                }
                Divider()
                HStack {
                    Label("Distance", systemImage: "ruler")
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.8))
                    Spacer()
                    Text(String(format: "%.2f km", healthManager.distanceTodayKm))
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Streaks Row (NEW)
private struct StreaksRowView: View {

    @ObservedObject var healthManager: HealthManager

    @State private var currentStreak: Int = 0
    @State private var bestStreak: Int = 0
    @State private var didCompleteToday: Bool = false

    private let storageKey = "fitforge.dailyStreakState"

    private struct StoredStreakState: Codable {
        var date: Date
        var currentStreak: Int
        var bestStreak: Int
        var didCompleteToday: Bool
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 8) {
                Text("🔥 Streak")
                    .font(.title3.bold())

                if didCompleteToday {
                    Text("Perfect today")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                } else {
                    Text("Keep pushing")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12))
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                }

                Spacer()
            }

            HStack(alignment: .center, spacing: 18) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currentStreak)")
                        .font(.system(size: 28, weight: .bold))
                    Text("Current days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(bestStreak)")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Best streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: didCompleteToday ? "flame.fill" : "flame")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(didCompleteToday ? .orange : .secondary)
            }
            .padding(.horizontal, 4)

            Text("A perfect day = Move, Steps & Hydration rings at ≥ 80% of their goal.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
        .onAppear {
            evaluateAndUpdateIfNeeded()
        }
        .onChange(of: healthManager.activeEnergyToday) { _, _ in
            evaluateAndUpdateIfNeeded()
        }
        .onChange(of: healthManager.stepsToday) { _, _ in
            evaluateAndUpdateIfNeeded()
        }
        .onChange(of: healthManager.hydrationLitersToday) { _, _ in
            evaluateAndUpdateIfNeeded()
        }
    }

    // MARK: - Streak Logic

    private func evaluateAndUpdateIfNeeded() {
        let active = healthManager.activeEnergyToday
        let activeGoal = max(healthManager.activeEnergyGoal, 1)

        let steps = healthManager.stepsToday
        let stepsGoal = max(healthManager.stepsGoal, 1)

        let water = healthManager.hydrationLitersToday
        let waterGoal = max(healthManager.hydrationGoalLiters, 0.1)

        let moveOK = Double(active) >= Double(activeGoal) * 0.8
        let stepsOK = Double(steps) >= Double(stepsGoal) * 0.8
        let waterOK = water >= waterGoal * 0.8

        let isPerfectToday = moveOK && stepsOK && waterOK

        updateStreakState(isPerfectToday: isPerfectToday)
    }

    private func updateStreakState(isPerfectToday: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var stored = loadStoredState()

        if let lastDate = stored?.date {
            let lastDay = calendar.startOfDay(for: lastDate)

            // Same day: just update today's completion flag, don't change streak length unless needed
            if lastDay == today {
                // Create a mutable copy
                var newState = stored!
                newState.didCompleteToday = isPerfectToday
                stored = newState
            } else {
                // New day
                let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

                var current = stored?.currentStreak ?? 0
                var best = stored?.bestStreak ?? 0

                if daysDiff == 1 {
                    // Consecutive day
                    if isPerfectToday {
                        current += 1
                        best = max(best, current)
                    } else {
                        current = 0
                    }
                } else {
                    // gap of 2+ days → reset
                    current = isPerfectToday ? 1 : 0
                    best = max(best, current)
                }

                stored = StoredStreakState(
                    date: today,
                    currentStreak: current,
                    bestStreak: best,
                    didCompleteToday: isPerfectToday
                )
            }

        } else {
            // No stored state yet
            let initialCurrent = isPerfectToday ? 1 : 0
            stored = StoredStreakState(
                date: today,
                currentStreak: initialCurrent,
                bestStreak: initialCurrent,
                didCompleteToday: isPerfectToday
            )
        }

        if let stored {
            saveStoredState(stored)
            currentStreak = max(stored.currentStreak, 0)
            bestStreak = max(stored.bestStreak, stored.currentStreak)
            didCompleteToday = stored.didCompleteToday
        } else {
            currentStreak = 0
            bestStreak = 0
            didCompleteToday = false
        }
    }

    private func loadStoredState() -> StoredStreakState? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode(StoredStreakState.self, from: data)
    }

    private func saveStoredState(_ state: StoredStreakState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
// MARK: - Daily Brief Model (kept here for now; extract to Models/DailyBrief.swift later)

struct DailyBrief {
    enum CTAAction {
        case generateMealPlan
        case openMealPlan
        case addWater
    }

    let headline: String
    let reason: String
    let ctaTitle: String
    let action: CTAAction
}

enum DailyBriefBuilder {

    /// Pure, local, rule-based. No network, no AI. First match wins.
    static func make(
        goal: String,
        goalCalories: Int,
        healthAuthorized: Bool,
        waterLiters: Double,
        waterGoalLiters: Double,
        sleepHours: Double,
        hasAnyPlan: Bool
    ) -> DailyBrief {

        // 1. No plan yet -> get them into the core loop.
        if !hasAnyPlan {
            return DailyBrief(
                headline: "Start with today's meals",
                reason: "Generate a plan around your \(goalCalories) kcal target so today's eating is sorted.",
                ctaTitle: "Generate Meal Plan",
                action: .generateMealPlan
            )
        }

        // 2. Low hydration (only when we actually have data).
        if healthAuthorized,
           waterGoalLiters > 0,
           waterLiters > 0,
           waterLiters < waterGoalLiters * 0.5 {
            return DailyBrief(
                headline: "Top up your water",
                reason: "You're at \(oneDP(waterLiters))L of \(oneDP(waterGoalLiters))L today - a couple of glasses gets you back on track.",
                ctaTitle: "Add 500 ml",
                action: .addWater
            )
        }

        // 3. Short sleep -> steer toward an easy, consistent day.
        if healthAuthorized, sleepHours > 0, sleepHours < 6 {
            return DailyBrief(
                headline: "Keep today easy",
                reason: "You slept \(oneDP(sleepHours))h last night - prioritize recovery and steady meals.",
                ctaTitle: "Open today's plan",
                action: .openMealPlan
            )
        }

        // 4. Default: on track.
        return DailyBrief(
            headline: "You're set for today",
            reason: defaultReason(goal: goal, goalCalories: goalCalories),
            ctaTitle: "Open today's plan",
            action: .openMealPlan
        )
    }

    private static func defaultReason(goal: String, goalCalories: Int) -> String {
        switch goal.lowercased() {
        case "lose fat", "fat-loss", "fatloss":
            return "Stay close to ~\(goalCalories) kcal and keep your rings moving."
        case "gain muscle", "muscle", "muscle gain":
            return "Hit ~\(goalCalories) kcal and your protein, then keep your rings moving."
        default:
            return "Aim for ~\(goalCalories) kcal and keep your rings moving."
        }
    }

    private static func oneDP(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}

