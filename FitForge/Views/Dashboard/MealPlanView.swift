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

    @StateObject private var progress = MealProgressStore()

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
                    progressSummarySection
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
            progress.load(planKey: stableKey(for: jsonText))
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

    // MARK: - PROGRESS SUMMARY
        private var totalMealCount: Int { mealPlan.count * 4 }

        private var progressSummarySection: some View {
            HStack {
                Text("Done: \(progress.completedCount) of \(totalMealCount)")
                    .font(.subheadline.bold())
                Spacer()
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

                        MealRow(title: "🍳 Breakfast", text: day.breakfast,
                                isChecked: progress.isChecked(mealKey(day, "breakfast")),
                                onToggle: { progress.toggle(mealKey(day, "breakfast")) })
                        MealRow(title: "🥗 Lunch", text: day.lunch,
                                isChecked: progress.isChecked(mealKey(day, "lunch")),
                                onToggle: { progress.toggle(mealKey(day, "lunch")) })
                        MealRow(title: "🍽 Dinner", text: day.dinner,
                                isChecked: progress.isChecked(mealKey(day, "dinner")),
                                onToggle: { progress.toggle(mealKey(day, "dinner")) })
                        MealRow(title: "🍎 Snack", text: day.snack,
                                isChecked: progress.isChecked(mealKey(day, "snack")),
                                onToggle: { progress.toggle(mealKey(day, "snack")) })
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
        }

        // MARK: - PROGRESS KEYS
        private func mealKey(_ day: MealDay, _ slot: String) -> String {
            "\(day.day)-\(slot)"
        }

        /// Deterministic FNV-1a 64-bit hash over the JSON bytes. Stable across
        /// launches (unlike Swift's randomized hashValue), so progress for the same
        /// plan content is shared across My Plans, Daily Brief, and fresh generation.
        private func stableKey(for source: String) -> String {
            var hash: UInt64 = 1469598103934665603
            let prime: UInt64 = 1099511628211
            for byte in source.utf8 {
                hash ^= UInt64(byte)
                hash = hash &* prime
            }
            return String(hash, radix: 16)
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
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isChecked ? .green : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .strikethrough(isChecked, color: .gray)
                }

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

// MARK: - MEAL PROGRESS STORE (local, inline; extract later if reused)
final class MealProgressStore: ObservableObject {
    @Published private(set) var checkedKeys: Set<String> = []

    private static let storageKey = "meal_plan_progress_v1"
    private var planKey: String = ""

    var completedCount: Int { checkedKeys.count }

    func load(planKey: String) {
        self.planKey = planKey
        checkedKeys = Set(Self.loadAll()[planKey] ?? [])
    }

    func isChecked(_ mealKey: String) -> Bool {
        checkedKeys.contains(mealKey)
    }

    func toggle(_ mealKey: String) {
        if checkedKeys.contains(mealKey) {
            checkedKeys.remove(mealKey)
        } else {
            checkedKeys.insert(mealKey)
        }
        persist()
    }

    private func persist() {
        var all = Self.loadAll()
        all[planKey] = checkedKeys.isEmpty ? nil : Array(checkedKeys)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private static func loadAll() -> [String: [String]] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
        else { return [:] }
        return decoded
    }
}


