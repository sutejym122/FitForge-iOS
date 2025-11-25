//
//  MacroChart.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/13/25.
//

import SwiftUI
import Charts

struct MacroChart: View {
    let result: MetabolicResult
    
    var data: [(String, Double)] {
        [
            ("Protein", result.protein),
            ("Carbs", result.carbs),
            ("Fats", result.fats)
        ]
    }
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { macro, grams in
                SectorMark(
                    angle: .value("Grams", grams),
                    innerRadius: .ratio(0.55)
                )
                .foregroundStyle(by: .value("Macro", macro))
            }
        }
        .chartLegend(.visible)
    }
}
