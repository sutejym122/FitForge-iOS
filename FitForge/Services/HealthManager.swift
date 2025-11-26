//
//  HealthManager.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/25/25.
//

import Foundation
import HealthKit

final class HealthManager: ObservableObject {

    // MARK: - Public Published Metrics

    @Published var activeEnergyToday: Double = 0   // kcal
    @Published var activeEnergyGoal: Double = 500  // default; you can tune or read from HK later

    @Published var stepsToday: Double = 0
    @Published var stepsGoal: Double = 10_000

    @Published var hydrationLitersToday: Double = 0
    @Published var hydrationGoalLiters: Double = 3.0

    @Published var sleepTotalHours: Double = 0
    @Published var sleepDeepHours: Double = 0
    @Published var sleepCoreHours: Double = 0
    @Published var sleepRemHours: Double = 0

    // MARK: - HealthKit Store

    private let healthStore = HKHealthStore()
    private var isAuthorized = false

    private var refreshTimer: Timer?

    init() {
        requestAuthorization()
    }

    // MARK: - Authorization

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ Health data not available on this device")
            return
        }

        // Quantity types
        guard
            let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            print("❌ Failed to create HK types")
            return
        }

        let readTypes: Set<HKObjectType> = [
            activeEnergyType,
            stepCountType,
            waterType,
            sleepType
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HealthKit auth error:", error)
                }
                self?.isAuthorized = success
                if success {
                    self?.startRefreshingData()
                } else {
                    print("❌ HealthKit authorization not granted")
                }
            }
        }
    }

    // MARK: - Timer-based refreshing for 'continuous' feel

    private func startRefreshingData() {
        // Initial load
        refreshAll()

        // Refresh roughly every 60 seconds
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshAll()
        }
    }

    func refreshAll() {
        guard isAuthorized else { return }
        fetchActiveEnergyToday()
        fetchStepsToday()
        fetchHydrationToday()
        fetchSleepLastNight()
    }

    // MARK: - Date Helpers

    private var todayStart: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var todayEnd: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
    }

    // MARK: - Active Energy

    private func fetchActiveEnergyToday() {
        guard let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: todayStart, end: todayEnd, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { [weak self] _, stats, _ in
            guard let self else { return }

            let unit = HKUnit.kilocalorie()
            let sum = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0

            DispatchQueue.main.async {
                self.activeEnergyToday = sum
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Steps

    private func fetchStepsToday() {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: todayStart, end: todayEnd, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { [weak self] _, stats, _ in
            guard let self else { return }

            let unit = HKUnit.count()
            let sum = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0

            DispatchQueue.main.async {
                self.stepsToday = sum
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Hydration (Dietary Water)

    private func fetchHydrationToday() {
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: todayStart, end: todayEnd, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { [weak self] _, stats, _ in
            guard let self else { return }

            // Apple typically stores water in liters
            let unit = HKUnit.liter()
            let sum = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0

            DispatchQueue.main.async {
                self.hydrationLitersToday = sum
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Sleep (Last Night, Stage Breakdown)

    private func fetchSleepLastNight() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        // Approx "last night": from yesterday 12:00pm to today 12:00pm
        let calendar = Calendar.current
        let now = Date()
        let todayNoon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now)!
        let yesterdayNoon = calendar.date(byAdding: .day, value: -1, to: todayNoon)!

        let predicate = HKQuery.predicateForSamples(withStart: yesterdayNoon, end: todayNoon, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sort]) { [weak self] _, samples, error in
            guard let self else { return }

            if let error = error {
                print("❌ Sleep query error:", error)
                return
            }

            guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                DispatchQueue.main.async {
                    self.sleepTotalHours = 0
                    self.sleepDeepHours = 0
                    self.sleepCoreHours = 0
                    self.sleepRemHours = 0
                }
                return
            }

            var total: TimeInterval = 0
            var deep: TimeInterval = 0
            var core: TimeInterval = 0
            var rem: TimeInterval = 0

            for sample in samples {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                total += duration

                if #available(iOS 16.0, *) {
                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                        deep += duration
                    case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                        core += duration
                    case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                        rem += duration
                    case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                         HKCategoryValueSleepAnalysis.asleep.rawValue:
                        core += duration
                    default:
                        break
                    }
                } else {
                    // Older iOS – just treat everything asleep as "core"
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        core += duration
                    }
                }
            }

            let toHours: (TimeInterval) -> Double = { $0 / 3600.0 }

            DispatchQueue.main.async {
                self.sleepTotalHours = toHours(total)
                self.sleepDeepHours = toHours(deep)
                self.sleepCoreHours = toHours(core)
                self.sleepRemHours  = toHours(rem)
            }
        }

        healthStore.execute(query)
    }
}
