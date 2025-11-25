//
//  CalorieCard.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import SwiftUI

struct CalorieCard: View {
    let result: MetabolicResult
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Goal Calories")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(Int(result.goalCalories)) kcal")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                info("BMR", "\(Int(result.bmr))")
                info("TDEE", "\(Int(result.tdee))")
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.9)
        )
        .cornerRadius(25)
        .shadow(color: .purple.opacity(0.4), radius: 20, x: 0, y: 10)
    }
    
    func info(_ title: String, _ value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
