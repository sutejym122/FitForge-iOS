//
//  MealPlanView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//




import SwiftUI

struct MealPlanView: View {

    let jsonText: String

    @State private var mealPlan: [MealDay] = []
    @State private var preferenceText: String = ""
    @State private var isRegenerating = false
    @State private var errorMessage: String?

    // MARK: - Country helper
    private var resolvedCountryName: String {
        guard let profile = ProfileStorage.shared.currentProfile else {
            return "United States"
        }

        let trimmed = profile.country.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }

        if let code = Locale.current.region?.identifier {
            return Locale.current.localizedString(forRegionCode: code) ?? code
        }

        return "United States"
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    headerSection
                    infoBannerSection
                    mealCardsSection
                }
                .padding(.top)
                .blur(radius: isRegenerating ? 4 : 0)
                .opacity(isRegenerating ? 0.4 : 1)
            }

            if isRegenerating {
                VStack {
                    ProgressView("Creating a new meal plan…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            parseJSON(from: jsonText)
        }
        .navigationTitle("Meal Plan")
    }

    // MARK: - HEADER
    private var headerSection: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 120)
            .overlay(
                VStack(alignment: .leading) {
                    Text("Your 7-Day Meal Plan")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("AI-generated based on your diet goals")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                }
                .padding()
            )
            .padding(.horizontal)
    }

    // MARK: - INFO BANNER + PREFERENCES
    private var infoBannerSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("Meal Plan Tailored for You")
                .font(.headline)

            Text("""
This 7-day plan was generated based on your goal, macros, and the country you selected in onboarding (\(resolvedCountryName)).

If you'd like a different type of cuisine or want me to use specific foods, tell me below and I'll generate a new meal plan for you.
""")
            .font(.subheadline)
            .foregroundColor(.gray)

            TextField("Tell me foods you prefer (e.g. more rice, no fish, high-protein Indian veg)…",
                      text: $preferenceText,
                      axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(2...4)
                .padding(.top, 4)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }

            Button {
                regenerateMealPlan()
            } label: {
                Text(isRegenerating ? "Generating…" : "Generate New Plan From My Preferences")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        preferenceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isRegenerating
                        ? Color.gray.opacity(0.5)
                        : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(preferenceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isRegenerating)
        }
        .padding(.horizontal)
    }

    // MARK: - MEAL CARDS
    private var mealCardsSection: some View {
        VStack(spacing: 16) {
            ForEach(mealPlan) { day in
                VStack(alignment: .leading, spacing: 10) {
                    Text("Day \(day.day)")
                        .font(.title3.bold())

                    MealRow(title: "🍳 Breakfast", text: day.breakfast)
                    MealRow(title: "🥗 Lunch", text: day.lunch)
                    MealRow(title: "🍽 Dinner", text: day.dinner)
                    MealRow(title: "🍎 Snack", text: day.snack)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - PARSER
    private func parseJSON(from source: String) {
        guard let data = source.data(using: .utf8) else { return }

        do {
            let decoded = try JSONDecoder().decode(MealPlanResponse.self, from: data)
            self.mealPlan = decoded.mealplan
        } catch {
            print("❌ JSON Parse Error:", error)
            self.errorMessage = "Could not read this meal plan. Please try again."
        }
    }

    // MARK: - Regenerate based on preferences
    private func regenerateMealPlan() {
        guard let profile = ProfileStorage.shared.currentProfile else {
            errorMessage = "Profile not found. Please restart the app."
            return
        }

        let macros = MetabolicCalculator.calculate(profile: profile)

        isRegenerating = true
        errorMessage = nil

        MealPlanService.generateMealPlan(
            country: resolvedCountryName,
            goal: profile.goal,
            calories: Int(macros.goalCalories),
            protein: Int(macros.protein),
            carbs: Int(macros.carbs),
            fats: Int(macros.fats),
            dietPreference: "mixed",
            preferences: preferenceText
        ) { response in
            DispatchQueue.main.async {
                self.isRegenerating = false

                guard let text = response else {
                    self.errorMessage = "Failed to generate a new plan. Please try again."
                    return
                }

                self.parseJSON(from: text)
            }
        }
    }
}

// MARK: - MEAL ROW COMPONENT
struct MealRow: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - MODELS
struct MealPlanResponse: Codable {
    let mealplan: [MealDay]
}

struct MealDay: Codable, Identifiable {
    var id: Int { day }
    let day: Int
    let breakfast: String
    let lunch: String
    let dinner: String
    let snack: String
}



