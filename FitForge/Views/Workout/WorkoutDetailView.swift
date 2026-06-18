//
//  WorkoutDetailView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/3/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var workoutStore: WorkoutStore

    // We store ID + fallback so that edits reflect when coming back
    private let workoutID: UUID
    private let fallbackWorkout: WorkoutEntry

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    init(workoutStore: WorkoutStore, workout: WorkoutEntry) {
        self.workoutStore = workoutStore
        self.workoutID = workout.id
        self.fallbackWorkout = workout
    }

    // Fetch latest version from store, or fallback to original
    private var workout: WorkoutEntry {
        workoutStore.workouts.first(where: { $0.id == workoutID }) ?? fallbackWorkout
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Text(workout.type)
                    .font(.largeTitle.bold())
                Spacer()
            }

            detailRow("Duration", "\(workout.durationMinutes) mins")
            detailRow("Calories Burned", "\(workout.caloriesBurned) kcal")
            detailRow(
                "Date",
                workout.date.formatted(date: .abbreviated, time: .shortened)
            )

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button("Edit") {
                    showEditSheet = true
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditWorkoutSheet(workoutStore: workoutStore, workout: workout)
        }
        .alert("Delete workout?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                workoutStore.deleteWorkout(workout)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

