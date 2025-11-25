//
//  ChatSession.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import Foundation

struct ChatSession: Identifiable, Codable {
    let id: UUID
    let startedAt: Date
    
    var goal: String
    var country: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int
    var difficultyLevel: String = "Beginner"
    
    var messages: [ChatMessage]
    
    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        goal: String,
        country: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fats: Int,
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.startedAt = startedAt
        self.goal = goal
        self.country = country
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.messages = messages
    }
}
