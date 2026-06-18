//
//  EditWorkoutSheet.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import SwiftUI

struct EditWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var workoutStore: WorkoutStore
    let workout: WorkoutEntry

    @State private var type: String
    @State private var durationMinutes: Int
    @State private var caloriesBurned: Int
    @State private var date: Date

    init(workoutStore: WorkoutStore, workout: WorkoutEntry) {
        self.workoutStore = workoutStore
        self.workout = workout

        _type = State(initialValue: workout.type)
        _durationMinutes = State(initialValue: workout.durationMinutes)
        _caloriesBurned = State(initialValue: workout.caloriesBurned)
        _date = State(initialValue: workout.date)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Workout") {
                    TextField("Type", text: $type)

                    Stepper("\(durationMinutes) mins", value: $durationMinutes, in: 1...300)

                    Stepper("\(caloriesBurned) kcal", value: $caloriesBurned, in: 10...2000)

                    DatePicker("Date", selection: $date)
                }
            }
            .navigationTitle("Edit Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        workoutStore.updateWorkout(
                            workout,
                            type: type,
                            durationMinutes: durationMinutes,
                            caloriesBurned: caloriesBurned,
                            date: date
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
