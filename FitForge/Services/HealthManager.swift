//
//  HealthManager.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/25/25.
//

import Foundation
import HealthKit
import Combine

final class HealthManager: ObservableObject {

    // MARK: - Published Properties

    @Published var activeEnergyToday: Double = 0
    @Published var activeEnergyGoal: Double = 500

    @Published var stepsToday: Double = 0
    @Published var stepsGoal: Double = 10000
    
    @Published var distanceTodayKm: Double = 0

    @Published var hydrationLitersToday: Double = 0
    @Published var hydrationGoalLiters: Double = 2.3

    @Published var sleepTotalHours: Double = 0
    @Published var sleepDeepHours: Double = 0
    @Published var sleepCoreHours: Double = 0
    @Published var sleepRemHours: Double = 0

    @Published var isAuthorized: Bool = false
    @Published var lastError: String?

    // MARK: - Weekly Data

    @Published var stepsLast7Days: [Int] = []
    @Published var hydrationLast7Days: [Double] = []
    @Published var sleepLast7Days: [Double] = []

    // MARK: - Private

    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        hydrationGoalLiters = Self.computeHydrationGoalFromProfile()
        requestAuthorization()
    }

    // MARK: - Hydration Goal

    private static func computeHydrationGoalFromProfile() -> Double {
        guard let profile = ProfileStorage.shared.currentProfile else { return 2.3 }

        let weightString = profile.weight.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let weightKg = Double(weightString), weightKg > 0 else { return 2.3 }

        let goal = weightKg * 0.033
        return min(max(goal, 1.5), 4.0)
    }

    // MARK: - Authorization

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async { self.lastError = "Health data not available." }
            return
        }

        guard
            let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            DispatchQueue.main.async { self.lastError = "Failed to create HK types." }
            return
        }

        let readTypes: Set<HKObjectType> = [
            activeEnergyType, stepType, distanceType, waterType, sleepType
        ]

        let writeTypes: Set<HKSampleType> = [waterType]

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.lastError = error.localizedDescription
                }
                self.isAuthorized = success
            }

            if success {
                self.refreshAll()
                self.fetchWeeklyData()
            }
        }
    }

    // MARK: - Public

    func refreshAll() {
        fetchActiveEnergyToday()
        fetchStepsToday()
        fetchTodayStepsAndDistance()
        fetchHydrationToday()
        fetchSleepForLastNight()
    }

    func addManualWater(amountLiters: Double) {
        guard amountLiters > 0 else { return }
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let now = Date()
        let quantity = HKQuantity(unit: .liter(), doubleValue: amountLiters)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: now, end: now)

        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                if success { self.hydrationLitersToday += amountLiters }
                else { self.lastError = error?.localizedDescription }
            }
        }
    }

    // MARK: - Helpers

    private var todayPredicate: NSPredicate {
        let start = Calendar.current.startOfDay(for: Date())
        return HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
    }

    private func executeStatisticsQuery(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        completion: @escaping (Double) -> Void
    ) {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(0); return
        }

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: todayPredicate, options: .cumulativeSum) {
            _, stats, _ in
            let value = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0
            DispatchQueue.main.async { completion(value) }
        }

        healthStore.execute(query)
    }

    // MARK: - Daily Fetchers

    private func fetchActiveEnergyToday() {
        executeStatisticsQuery(for: .activeEnergyBurned, unit: .kilocalorie()) {
            self.activeEnergyToday = $0
        }
    }

    private func fetchStepsToday() {
        executeStatisticsQuery(for: .stepCount, unit: .count()) {
            self.stepsToday = $0
        }
    }

    func fetchTodayStepsAndDistance() {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        // Steps
        let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            _, stats, _ in
            DispatchQueue.main.async {
                self.stepsToday = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            }
        }

        // Distance
        let distQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            _, stats, _ in
            DispatchQueue.main.async {
                let meters = stats?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                self.distanceTodayKm = meters / 1000.0
            }
        }

        healthStore.execute(stepsQuery)
        healthStore.execute(distQuery)
    }

    private func fetchHydrationToday() {
        executeStatisticsQuery(for: .dietaryWater, unit: .liter()) {
            self.hydrationLitersToday = $0
        }
    }

    private func fetchSleepForLastNight() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let now = Date()
        let start = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        let predicate = HKQuery.predicateForSamples(withStart: start, end: now)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
            _, samples, _ in

            let samples = samples as? [HKCategorySample] ?? []
            var total: TimeInterval = 0
            var deep: TimeInterval = 0
            var core: TimeInterval = 0
            var rem: TimeInterval = 0

            for sample in samples {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)

                switch sample.value {
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue: deep += duration; total += duration
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue: core += duration; total += duration
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:  rem += duration; total += duration
                case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                    total += duration
                default: break
                }
            }

            DispatchQueue.main.async {
                self.sleepTotalHours = total / 3600
                self.sleepDeepHours  = deep  / 3600
                self.sleepCoreHours  = core  / 3600
                self.sleepRemHours   = rem   / 3600
            }
        }

        healthStore.execute(query)
    }

    // MARK: - WEEKLY FETCHERS
    func fetchWeeklyData() {
        fetchStepsLast7Days()
        fetchHydrationLast7Days()
        fetchSleepLast7Days()
    }

    func fetchStepsLast7Days() {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }

        let calendar = Calendar.current
        let now = Date()
        var results: [Int] = []
        let group = DispatchGroup()

        for offset in (0..<7).reversed() {
            group.enter()

            let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: now)!)
            let end   = calendar.date(byAdding: .day, value: 1, to: start)!

            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) {
                _, stats, _ in
                let steps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                results.append(Int(steps))
                group.leave()
            }

            self.healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.stepsLast7Days = results
        }
    }

    func fetchHydrationLast7Days() {
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let calendar = Calendar.current
        let now = Date()
        var results: [Double] = []
        let group = DispatchGroup()

        for offset in (0..<7).reversed() {
            group.enter()

            let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: now)!)
            let end   = calendar.date(byAdding: .day, value: 1, to: start)!

            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) {
                _, stats, _ in
                let liters = stats?.sumQuantity()?.doubleValue(for: .liter()) ?? 0
                results.append(liters)
                group.leave()
            }

            self.healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.hydrationLast7Days = results
        }
    }

    func fetchSleepLast7Days() {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let now = Date()
        let calendar = Calendar.current
        var results: [Double] = []
        let group = DispatchGroup()

        for offset in (0..<7).reversed() {
            group.enter()

            let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: now)!)
            let end   = calendar.date(byAdding: .day, value: 1, to: start)!

            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
                _, samples, _ in

                let samples = samples as? [HKCategorySample] ?? []
                var total: TimeInterval = 0

                for s in samples {
                    if s.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                        s.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                        s.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                        s.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue {
                        total += s.endDate.timeIntervalSince(s.startDate)
                    }
                }

                results.append(total / 3600)
                group.leave()
            }

            self.healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.sleepLast7Days = results
        }
    }
}


