//
//  DietPreferenceSheet.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/20/25.
//

import SwiftUI

/// Sheet that lets the user pick veg / non-veg / mixed before generating a plan.
struct DietPreferenceSheet: View {
    let current: DietPreference
    let country: String
    let onSelect: (DietPreference) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Build Your Meal Plan")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Please choose what you’re okay eating. Your plan will be based on your goal, macros, and common foods in \(country).")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 14) {
                    ForEach(DietPreference.allCases) { pref in
                        Button {
                            onSelect(pref)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: pref == current ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.blue)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pref.displayName)
                                        .font(.headline)
                                    Text(pref.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(14)
                        }
                    }
                }

                Spacer()

                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .foregroundColor(.red.opacity(0.8))
            }
            .padding()
            .navigationTitle("Diet Preference")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

