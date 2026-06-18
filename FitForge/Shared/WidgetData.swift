//
//  WidgetData.swift
//  FitForge
//
//  Created by Sutej  Ym  on 12/8/25.
//

import Foundation

struct WidgetData: Codable {
    let stepsToday: Int
    let hydrationToday: Double
    let activeEnergyToday: Double
    let streak: Int
    let weeklyInsight: String
}
