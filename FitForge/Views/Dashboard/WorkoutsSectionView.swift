//
//  WorkoutsSectionView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/3/25.
//

import SwiftUI

struct WorkoutsSectionView: View {
    @ObservedObject var workoutStore: WorkoutStore
    @State private var showAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Workouts")
                    .font(.title3.bold())

                Spacer()

                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }

            if workoutStore.workouts.isEmpty {
                Text("No workouts logged yet!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(recentWorkouts) { w in
                    WorkoutRow(workout: w)
                }
            }

            NavigationLink("View All Workouts →") {
                AllWorkoutsListView(workoutStore: workoutStore)
            }
            .font(.subheadline.bold())
        }
        .sheet(isPresented: $showAddSheet) {
            AddWorkoutSheet(workoutStore: workoutStore)
        }
    }

    private var recentWorkouts: [WorkoutEntry] {
        workoutStore.workouts
            .sorted(by: { $0.date > $1.date })
            .prefix(3)
            .map { $0 }
    }
}

struct WorkoutRow: View {
    let workout: WorkoutEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workout.type)
                    .font(.headline)

                Text("\(workout.durationMinutes) mins • \(workout.caloriesBurned) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(workout.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}
