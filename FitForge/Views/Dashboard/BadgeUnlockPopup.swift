//
//  BadgeUnlockPopup.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/28/25.
//

import SwiftUI

struct BadgeUnlockPopup: View {
    let badge: AchievementsSectionView.AchievementBadge
    let onDismiss: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { dismissPopup() }

            // Popup card
            VStack(spacing: 16) {

                // Icon with animation
                ZStack {
                    Circle()
                        .fill(badge.accentColor.opacity(0.25))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animate ? 1.0 : 0.6)
                        .opacity(animate ? 1.0 : 0.0)

                    Image(systemName: badge.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(badge.accentColor)
                        .scaleEffect(animate ? 1.0 : 0.5)
                        .opacity(animate ? 1.0 : 0.0)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animate)

                VStack(spacing: 6) {
                    Text("Achievement Unlocked!")
                        .font(.title3.bold())
                        .foregroundColor(.primary)

                    Text(badge.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(badge.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: dismissPopup) {
                    Text("Continue")
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(badge.accentColor.opacity(0.2))
                        )
                }
                .padding(.top, 12)

            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
            .onAppear {
                // Animation delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animate = true
                }
                // Haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private func dismissPopup() {
        animate = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}
