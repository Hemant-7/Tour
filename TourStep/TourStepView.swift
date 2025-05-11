//
//  TourStepView.swift
//  TourStep
//
//  Created by Hemant kumar on 09/05/25.
//

import SwiftUI

// MARK: - Main View
struct TourDemoView: View {
    @State private var currentStep: String? = "home"
    
    let steps: [TourStep] = [
        TourStep(id: "home", title: "Home", description: "Home Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        TourStep(id: "bookmark", title: "Bookmarks", description: "Bookmarks Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        TourStep(id: "profile", title: "Profile", description: "Profile Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
    ]
    
    var body: some View {
        
        VStack(spacing: 16) {
            Text("Home")
                .padding()
                .foregroundColor(.blue)
                .tourAnchor(id: "home", currentStep: $currentStep, steps: steps)
            HStack {
                Text("Bookmarks")
                    .padding()
                    .foregroundColor(.blue)
                    .tourAnchor(id: "bookmark", currentStep: $currentStep, steps: steps)
                Spacer()
                Text("Profile")
                    .padding()
                    .foregroundColor(.blue)
                    .tourAnchor(id: "profile", currentStep: $currentStep, steps: steps)
            }
            .padding()
            
        }
        .padding()
    }
}

#Preview {
    TourDemoView()
}
