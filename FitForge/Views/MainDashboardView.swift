//
//  ContentView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/11/25.
//

import SwiftUI

struct MainDashboardView: View {
    var body: some View {
        DashboardView()
    }
}


//import SwiftUI
//
//struct MainDashboardView: View {
//    @State private var country = ""
//    @State private var weight = ""
//    @State private var height = ""
//    @State private var goal = ""
//    @State private var responseText = "No plan generated yet"
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Your Details")) {
//                    TextField("Country", text: $country)
//                    TextField("Weight (kg)", text: $weight)
//                        .keyboardType(.decimalPad)
//                    TextField("Height (cm)", text: $height)
//                        .keyboardType(.decimalPad)
//                    TextField("Goal (e.g. lose fat, gain muscle)", text: $goal)
//                }
//
//                Button(action: generatePlan) {
//                    HStack {
//                        Spacer()
//                        Text("Generate Plan")
//                            .fontWeight(.bold)
//                        Spacer()
//                    }
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//                }
//
//                Section(header: Text("Result")) {
//                    Text(responseText)
//                        .padding(.vertical)
//                }
//            }
//            .navigationTitle("FitForge")
//        }
//    }
//
//    func generatePlan() {
//        guard let url = URL(string: "http://127.0.0.1:8000/generate-plan") else { return }
//        let payload: [String: Any] = [
//            "country": country,
//            "weight": weight,
//            "height": height,
//            "goal": goal
//        ]
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let data = data {
//                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let plan = jsonResponse["plan"] as? String {
//                    DispatchQueue.main.async {
//                        self.responseText = plan
//                    }
//                }
//            } else if let error = error {
//                DispatchQueue.main.async {
//                    self.responseText = "Error: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//}
