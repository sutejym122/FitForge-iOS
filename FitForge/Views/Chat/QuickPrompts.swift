//
//  QuickPrompts.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/19/25.
//

import Foundation

struct QuickPrompts {

    static func prompts(for goal: String) -> [String] {
        let lower = goal.lowercased()

        if lower.contains("lose") || lower.contains("fat") || lower.contains("cut") {
            return [
                "Give me today's fat-loss workout",
                "Suggest a 20-minute HIIT session",
                "Give me a low-calorie high-protein dinner idea",
                "How do I reduce belly fat safely?"
            ]
        }

        if lower.contains("gain") || lower.contains("bulk") || lower.contains("muscle") {
            return [
                "Give me a push day workout",
                "Give me a heavy leg day plan",
                "Suggest a 3,000 calorie clean bulk meal plan",
                "How do I increase my bench press?"
            ]
        }

        // Maintain / general fitness
        return [
            "Give me a full body workout for today",
            "Suggest a 30-minute home workout",
            "Give me a healthy high-protein snack idea",
            "How should I warm up before lifting?"
        ]
    }
}

