//
//  ProfileAvatarView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/24/25.
//

import SwiftUI

struct ProfileAvatarView: View {
    let profile: UserProfile
    var size: CGFloat = 36

    var body: some View {
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
}
