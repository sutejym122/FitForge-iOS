//
//  OnboardingView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

//import SwiftUI
//
//struct OnboardingView: View {
//    @State private var step = 0
//    @State private var profile = UserProfile()
//    @State private var navigateToDashboard = false
//    @AppStorage(StorageKeys.isOnboarded) var isOnboarded = false
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 30) {
//                Text("FitForge")
//                    .font(.largeTitle.bold())
//                    .padding(.top, 40)
//
//                Group {
//                    switch step {
//                    case 0:
//                        onboardingField(title: "What's your name?", text: $profile.name)
//                    case 1:
//                        genderPicker
//                    case 2:
//                        onboardingField(title: "How old are you?", text: $profile.age)
//                    case 3:
//                        onboardingField(title: "Height (cm)", text: $profile.height)
//                            .keyboardType(.decimalPad)
//                    case 4:
//                        onboardingField(title: "Weight (kg)", text: $profile.weight)
//                            .keyboardType(.decimalPad)
//                    case 5:
//                        activityPicker
//                    case 6:
//                        goalPicker
//                    default:
//                        EmptyView()
//                    }
//                }
//
//                Button(action: nextStep) {
//                    Text(step < 6 ? "Next" : "Continue")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(12)
//                }
//                .padding(.horizontal)
//
//                NavigationLink(destination: MainDashboardView(), isActive: $navigateToDashboard) {
//                    EmptyView()
//                }
//
//                Spacer()
//            }
//            .padding()
//        }
//    }
//
//    private func onboardingField(title: String, text: Binding<String>) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.headline)
//            TextField("", text: text)
//                .textFieldStyle(.roundedBorder)
//        }
//        .animation(.easeInOut, value: step)
//    }
//
//    private var genderPicker: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Select your gender")
//                .font(.headline)
//            Picker("Gender", selection: $profile.gender) {
//                Text("Male").tag("Male")
//                Text("Female").tag("Female")
//                Text("Other").tag("Other")
//            }
//            .pickerStyle(.segmented)
//        }
//    }
//
//    private var activityPicker: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Activity Level")
//                .font(.headline)
//            Picker("Activity Level", selection: $profile.activityLevel) {
//                Text("Sedentary").tag("Sedentary")
//                Text("Active").tag("Active")
//                Text("Very Active").tag("Very Active")
//            }
//            .pickerStyle(.segmented)
//        }
//    }
//
//    private var goalPicker: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("What's your goal?")
//                .font(.headline)
//            Picker("Goal", selection: $profile.goal) {
//                Text("Lose Fat").tag("Lose Fat")
//                Text("Gain Muscle").tag("Gain Muscle")
//                Text("Maintain").tag("Maintain")
//            }
//            .pickerStyle(.segmented)
//        }
//    }
//    
//    func saveProfile() {
//        do {
//            let encoded = try JSONEncoder().encode(profile)
//            UserDefaults.standard.set(encoded, forKey: StorageKeys.userProfile)
//        } catch {
//            print("❌ Failed to save profile:", error)
//        }
//    }
//
//
//    private func nextStep() {
//        if step < 6 {
//            step += 1
//        } else {
//            // later we’ll store this in AppStorage
//            saveProfile()
//            isOnboarded = true
//
//        }
//    }
//}


import SwiftUI
import PhotosUI

struct OnboardingView: View {

    // MARK: - Callback to return completed profile
    var onComplete: (UserProfile) -> Void

    // MARK: - Onboarding State
    @State private var step = 0
    @State private var profile = UserProfile.empty

    // Photo selection
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var avatarImageData: Data? = nil

    let countries = [
        "United States",
        "India",
        "Canada",
        "United Kingdom",
        "Australia",
        "Germany",
        "France",
        "Singapore",
        "UAE",
        "Other"
    ]

    @AppStorage(StorageKeys.isOnboarded) var isOnboarded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {

                Text("FitForge")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)

                Group {
                    switch step {

                    case 0:
                        onboardingField(title: "What's your name?",
                                        text: $profile.name)

                    case 1:
                        usernameField

                    case 2:
                        genderPicker

                    case 3:
                        onboardingField(title: "How old are you?",
                                        text: $profile.age)

                    case 4:
                        onboardingField(title: "Height (cm)",
                                        text: $profile.height)
                            .keyboardType(.decimalPad)

                    case 5:
                        onboardingField(title: "Weight (kg)",
                                        text: $profile.weight)
                            .keyboardType(.decimalPad)

                    case 6:
                        activityPicker

                    case 7:
                        goalPicker

                    case 8:
                        countryPicker

                    case 9:
                        profilePictureStep

                    default:
                        EmptyView()
                    }
                }

                Button(action: nextStep) {
                    Text(step < 9 ? "Next" : "Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Username field
    private var usernameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose a username")
                .font(.headline)

            TextField("@yourhandle", text: $profile.username)
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)

            Text("This will be shown as @username on your profile.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .animation(.easeInOut, value: step)
    }

    // MARK: - Profile Picture Step
    private var profilePictureStep: some View {
        VStack(spacing: 20) {
            Text("Set up your profile picture")
                .font(.headline)

            Text("You can also set this up later.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Preview
            if let data = avatarImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 110, height: 110)

                    Text(profile.initials)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                }
            }

            // Choose photo
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Text("Choose a Photo")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .onChange(of: pickerItem) { newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        avatarImageData = data
                    }
                }
            }

            // Skip
            Button("Set up later") {
                avatarImageData = nil
                nextStep() // at step 9 this will finalize
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Reusable field UI
    private func onboardingField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            TextField("", text: text)
                .textFieldStyle(.roundedBorder)
        }
        .animation(.easeInOut, value: step)
    }

    // MARK: - Gender Picker
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select your gender")
                .font(.headline)
            Picker("Gender", selection: $profile.gender) {
                Text("Male").tag("Male")
                Text("Female").tag("Female")
                Text("Other").tag("Other")
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Activity Level Picker
    private var activityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity Level")
                .font(.headline)
            Picker("Activity Level", selection: $profile.activityLevel) {
                Text("Sedentary").tag("Sedentary")
                Text("Active").tag("Active")
                Text("Very Active").tag("Very Active")
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Goal Picker
    private var goalPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's your goal?")
                .font(.headline)
            Picker("Goal", selection: $profile.goal) {
                Text("Lose Fat").tag("Lose Fat")
                Text("Gain Muscle").tag("Gain Muscle")
                Text("Maintain").tag("Maintain")
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Country Picker
    private var countryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Which country do you live in?")
                .font(.headline)

            Picker("Country", selection: $profile.country) {
                ForEach(countries, id: \.self) { country in
                    Text(country).tag(country)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
    }

    // MARK: - FINALIZE ONBOARDING
    private func finalizeOnboarding() {
        var finalProfile = profile
        finalProfile.avatarImageData = avatarImageData

        // Save via ProfileStorage (source of truth)
        ProfileStorage.shared.saveProfile(finalProfile)

        // Also keep your old StorageKeys-based save for safety
        do {
            let encoded = try JSONEncoder().encode(finalProfile)
            UserDefaults.standard.set(encoded, forKey: StorageKeys.userProfile)
            isOnboarded = true
            onComplete(finalProfile)
        } catch {
            print("❌ Failed to save profile:", error)
        }
    }

    // MARK: - Step Logic
    private func nextStep() {
        if step < 9 {
            step += 1
        } else {
            finalizeOnboarding()
        }
    }
}



