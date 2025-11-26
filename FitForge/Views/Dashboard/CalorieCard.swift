//
//  CalorieCard.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import SwiftUI

struct CalorieCard: View {
    let result: MetabolicResult
    let profile: UserProfile

    @State private var animate = false
    @State private var isPressed = false
    @State private var showRipple = false
    @State private var rippleScale: CGFloat = 0.1
    @State private var rippleOpacity: CGFloat = 0.4

    // MARK: - Goal Badge
    private var goalBadge: (icon: String, label: String, gradient: [Color]) {
        switch profile.goal.lowercased() {
        case "fat-loss", "fatloss", "lose fat":
            return ("🔥", "Fat-loss", [Color.red.opacity(0.4), Color.orange.opacity(0.4)])
        case "muscle", "muscle gain", "gain muscle":
            return ("💪", "Muscle Gain", [Color.green.opacity(0.35), Color.blue.opacity(0.35)])
        default:
            return ("⚖️", "Maintain", [Color.purple.opacity(0.35), Color.blue.opacity(0.35)])
        }
    }

    var body: some View {

        ZStack {
            
            // MARK: - Ripple Effect Layer
            if showRipple {
                Circle()
                    .fill(Color.white.opacity(rippleOpacity))
                    .scaleEffect(rippleScale)
                    .frame(width: 10, height: 10)
                    .animation(.easeOut(duration: 0.45), value: rippleScale)
                    .animation(.easeOut(duration: 0.45), value: rippleOpacity)
            }

            VStack(spacing: 15) {

                // MARK: - Goal Badge
                HStack {
                    HStack(spacing: 6) {
                        Text(goalBadge.icon)
                            .font(.system(size: 15))

                        Text(goalBadge.label)
                            .font(.subheadline.bold())
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(.white.opacity(0.6))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

                    Spacer()
                }

                // MARK: - Title
                Text("Goal Calories")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.55))

                // MARK: - Calories
                Text("\(Int(result.goalCalories)) kcal")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.purple.opacity(0.22), radius: animate ? 22 : 8)
                    .scaleEffect(animate ? 1.015 : 1.0)   // breathing animation

                // MARK: - BMR / TDEE
                HStack(spacing: 20) {
                    info("BMR", "\(Int(result.bmr))")
                    info("TDEE", "\(Int(result.tdee))")
                }
                .padding(.top, 4)

            }
            .padding(26)
            .frame(maxWidth: .infinity)
        }

        // MARK: - Background + Styling
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)

        // MARK: - TAP ANIMATIONS (Shrink + Ripple)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            performTapRipple()
        }

        // MARK: - Breathing Glow
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }

    // MARK: - Ripple Animation Logic
    private func performTapRipple() {
        isPressed = true

        // Reset ripple before playing again
        rippleScale = 0.1
        rippleOpacity = 0.4
        showRipple = true

        withAnimation(.easeOut(duration: 0.45)) {
            rippleScale = 2.6    // expand outward
            rippleOpacity = 0.0  // fade to invisible
        }

        // Reset pressed state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isPressed = false
        }

        // Remove ripple after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            showRipple = false
        }
    }

    // MARK: - Background
    private var cardBackground: some View {
        ZStack {

            LinearGradient(
                colors: goalBadge.gradient,
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .opacity(0.28)

            Color.white.opacity(0.55)

            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1.0)
                .shadow(color: .white.opacity(0.7), radius: 6, x: -3, y: -3)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }

    // MARK: - Info Labels
    func info(_ title: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.45))

            Text(value)
                .font(.title3.bold())
                .foregroundColor(.black.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
    }
}












