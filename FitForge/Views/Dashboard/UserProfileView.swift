//
//  UserProfileView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/24/25.
//

import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var profile: UserProfile
    @State private var pickerItem: PhotosPickerItem? = nil

    @State private var showEditBasic = false
    @State private var showEditHealth = false
    @State private var showEditGoals = false

    init(profile: UserProfile) {
        _profile = State(initialValue: profile)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Top profile card
                    profileCard

                    // Notifications (placeholder for future)
                    singleRowCard(title: "Notifications")

                    // Health / Goals / Units / Privacy
                    sectionCard {
                        sectionRow(title: "Health Details") {
                            showEditHealth = true
                        }
                        dividerLine
                        sectionRow(title: "Change Goals") {
                            showEditGoals = true
                        }
                        dividerLine
                        sectionRow(title: "Units of Measure") {
                            // hook up later if you add units
                        }
                        dividerLine
                        sectionRow(title: "Privacy") {
                            // hook up later (policy / data export, etc.)
                        }
                    }

                    // Workout / Fitness+ style section
                    sectionCard {
                        sectionRow(title: "Workout", accent: .green) {
                            // future: navigate to workout settings
                        }
                        dividerLine
                        sectionRow(title: "Fitness+", accent: .green) {
                            // future: subscriptions / premium
                        }
                    }

                    // Gift-card-like section
                    sectionCard {
                        sectionRow(title: "Redeem Gift Card or Code", accent: .green) {
                            // future
                        }
                        dividerLine
                        sectionRow(title: "Send Gift Card by Email", accent: .green) {
                            // future
                        }
                    }

                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 30, height: 30)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            // Sheets for editing
            .sheet(isPresented: $showEditBasic) {
                EditBasicInfoView(profile: $profile) {
                    saveProfile()
                }
            }
            .sheet(isPresented: $showEditHealth) {
                EditHealthDetailsView(profile: $profile) {
                    saveProfile()
                }
            }
            .sheet(isPresented: $showEditGoals) {
                EditGoalsView(profile: $profile) {
                    saveProfile()
                }
            }
            .onChange(of: pickerItem) { newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        profile.avatarImageData = data
                        saveProfile()
                    }
                }
            }
        }
    }

    // MARK: - Top profile card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {

                avatarView(size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name.isEmpty ? "Your Name" : profile.name)
                        .font(.headline)

                    Text(profile.username.isEmpty ? "@username" : "@\(profile.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showEditBasic = true
            }

            HStack(spacing: 20) {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Text("Change Photo")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                }

                Button(role: .destructive) {
                    profile.avatarImageData = nil
                    saveProfile()
                } label: {
                    Text("Remove Photo")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(24)
        .padding(.horizontal)
    }

    // MARK: - Avatar View

    private func avatarView(size: CGFloat) -> some View {
        Group {
            if let data = profile.avatarImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                    Text(profile.initials)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
        .shadow(radius: 1)
    }

    // MARK: - Reusable card & row helpers

    private func singleRowCard(title: String) -> some View {
        sectionCard {
            sectionRow(title: title) { }
        }
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(24)
        .padding(.horizontal)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
            .padding(.leading, 20)
    }

    private func sectionRow(title: String,
                            accent: Color? = nil,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(accent ?? .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Save

    private func saveProfile() {
        ProfileStorage.shared.saveProfile(profile)
    }
}

// MARK: - Edit Basic Info (Name + Username)

private struct EditBasicInfoView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var username: String
    let onSave: () -> Void

    init(profile: Binding<UserProfile>, onSave: @escaping () -> Void) {
        _profile = profile
        _name = State(initialValue: profile.wrappedValue.name)
        _username = State(initialValue: profile.wrappedValue.username)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Your name", text: $name)
                }

                Section("Username") {
                    TextField("@username", text: $username)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        profile.name = name
                        profile.username = username
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Edit Health Details

private struct EditHealthDetailsView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void

    @State private var age: String
    @State private var height: String
    @State private var weight: String
    @State private var activityLevel: String
    @State private var country: String

    init(profile: Binding<UserProfile>, onSave: @escaping () -> Void) {
        _profile = profile
        _age = State(initialValue: profile.wrappedValue.age)
        _height = State(initialValue: profile.wrappedValue.height)
        _weight = State(initialValue: profile.wrappedValue.weight)
        _activityLevel = State(initialValue: profile.wrappedValue.activityLevel)
        _country = State(initialValue: profile.wrappedValue.country)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }

                Section("Lifestyle") {
                    Picker("Activity Level", selection: $activityLevel) {
                        Text("Sedentary").tag("Sedentary")
                        Text("Active").tag("Active")
                        Text("Very Active").tag("Very Active")
                    }
                }

                Section("Country") {
                    TextField("Country", text: $country)
                }
            }
            .navigationTitle("Health Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        profile.age = age
                        profile.height = height
                        profile.weight = weight
                        profile.activityLevel = activityLevel
                        profile.country = country
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Edit Goals

private struct EditGoalsView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void

    @State private var goal: String

    init(profile: Binding<UserProfile>, onSave: @escaping () -> Void) {
        _profile = profile
        _goal = State(initialValue: profile.wrappedValue.goal)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    Picker("Goal", selection: $goal) {
                        Text("Lose Fat").tag("Lose Fat")
                        Text("Gain Muscle").tag("Gain Muscle")
                        Text("Maintain").tag("Maintain")
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Change Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        profile.goal = goal
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

