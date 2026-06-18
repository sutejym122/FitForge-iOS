//
//  AllWorkoutsListView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/3/25.
//

import SwiftUI

struct AllWorkoutsListView: View {      
    @ObservedObject var workoutStore: WorkoutStore

    // Filter state
    enum WorkoutFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case strength = "Strength"
        case cardio = "Cardio"

        var id: String { rawValue }
    }

    @State private var selectedFilter: WorkoutFilter = .all

    // Delete confirmation state
    @State private var workoutToDelete: WorkoutEntry?
    @State private var showDeleteAlert = false

    private var sortedWorkouts: [WorkoutEntry] {
        workoutStore.workouts.sorted { $0.date > $1.date }
    }

    private var filteredWorkouts: [WorkoutEntry] {
        switch selectedFilter {
        case .all:
            return sortedWorkouts
        case .strength:
            return sortedWorkouts.filter {
                $0.type.lowercased().contains("strength") ||
                $0.type.lowercased().contains("push") ||
                $0.type.lowercased().contains("pull") ||
                $0.type.lowercased().contains("legs") ||
                $0.type.lowercased().contains("chest") ||
                $0.type.lowercased().contains("back")
            }
        case .cardio:
            return sortedWorkouts.filter {
                $0.type.lowercased().contains("run") ||
                $0.type.lowercased().contains("walk") ||
                $0.type.lowercased().contains("cardio") ||
                $0.type.lowercased().contains("cycle") ||
                $0.type.lowercased().contains("bike")
            }
        }
    }

    var body: some View {
        VStack {
            // Filter picker
            Picker("Filter", selection: $selectedFilter) {
                ForEach(WorkoutFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            List {
                ForEach(filteredWorkouts) { workout in
                    NavigationLink {
                        WorkoutDetailView(workoutStore: workoutStore, workout: workout)
                    } label: {
                        WorkoutRow(workout: workout)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            workoutToDelete = workout
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("All Workouts")
        .alert("Delete workout?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let toDelete = workoutToDelete {
                    workoutStore.deleteWorkout(toDelete)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

