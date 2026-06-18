//
//  AddWorkoutSheet.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/3/25.
//

import SwiftUI

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutStore: WorkoutStore

    @State private var type: String = ""
    @State private var duration: String = ""
    @State private var calories: String = ""

    var body: some View {
        NavigationView {
            Form {

                Section("Workout Type") {
                    TextField("e.g. Running, Push Day, Legs", text: $type)
                }

                Section("Duration (minutes)") {
                    TextField("e.g. 45", text: $duration)
                        .keyboardType(.numberPad)
                }

                Section("Calories Burned") {
                    TextField("e.g. 300", text: $calories)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard
                            let dur = Int(duration),
                            let cal = Int(calories),
                            !type.isEmpty
                        else { return }

                        let newWorkout = WorkoutEntry(
                            type: type,
                            durationMinutes: dur,
                            caloriesBurned: cal
                        )

                        workoutStore.addWorkout(newWorkout)
                        dismiss()
                    }
                }
            }
        }
    }
}

