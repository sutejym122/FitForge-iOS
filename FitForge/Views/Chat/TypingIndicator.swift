//
//  TypingIndicator.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/19/25.
//

import SwiftUI

struct TypingIndicator: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        HStack(spacing: 6) {
            Circle().frame(width: 8, height: 8)
            Circle().frame(width: 8, height: 8)
            Circle().frame(width: 8, height: 8)
        }
        .foregroundColor(.gray)
        .padding(12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(0.8)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                phase = 1
            }
        }
    }
}
