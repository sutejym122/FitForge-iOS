//
//  WorkoutStore.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/3/25.
//

import Foundation

final class WorkoutStore: ObservableObject {

    @Published var workouts: [WorkoutEntry] = [] {
        didSet { saveWorkouts() }
    }

    private let saveKey = "user_workouts_data"

    init() {
        loadWorkouts()
    }

    func addWorkout(_ w: WorkoutEntry) {
        workouts.append(w)
    }

    func deleteWorkout(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
    }

    /// Delete by workout instance (used for swipe/delete with filters or from detail view)
    func deleteWorkout(_ workout: WorkoutEntry) {
        workouts.removeAll { $0.id == workout.id }
    }

    /// Update an existing workout in-place by id.
    func updateWorkout(
        _ workout: WorkoutEntry,
        type: String,
        durationMinutes: Int,
        caloriesBurned: Int,
        date: Date
    ) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index].type = type
            workouts[index].durationMinutes = durationMinutes
            workouts[index].caloriesBurned = caloriesBurned
            workouts[index].date = date
        }
    }

    // MARK: - Persistence

    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadWorkouts() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data)
        else { return }
        
        self.workouts = decoded
    }
}


