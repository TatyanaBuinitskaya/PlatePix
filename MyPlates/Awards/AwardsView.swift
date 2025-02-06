//
//  AwardsView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 24.12.2024.
//

import SwiftUI

/// A view that displays all available awards in a grid layout, allowing users to see their achievements.
struct AwardsView: View {
    /// The data controller for managing application data and award status.
    @EnvironmentObject var dataController: DataController
    /// The currently selected award for displaying details in an alert.
    @State private var selectedAward = Award.example
    /// A Boolean value that determines whether the award details alert is presented.
    @State private var showingAwardDetails = false
    /// The layout configuration for the grid, adapting between a minimum and maximum width.
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 150))]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            VStack {
                                Image(systemName: award.image)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal)
                                    .frame(width: 100, height: 100)
                                Text("\(award.value)")
                                    .font(.title2)
                            }
                            .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(
                            label(for: award)
                        )
                        .accessibilityHint(award.description)
                        .accessibilityValue(dataController.hasEarned(award: award) ? "Unlocked" : "Locked")
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }
    
    /// The title for the award details alert, indicating whether the award is unlocked.
    var awardTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }

    /// Determines the color to be displayed for an award based on whether it has been earned.
        /// - Parameter award: The award to evaluate.
        /// - Returns: A `Color` indicating the award status.
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    /// Provides an accessibility label for an award, indicating its status.
        /// - Parameter award: The award to generate the label for.
        /// - Returns: A `LocalizedStringKey` describing the award status.
    func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
}

#Preview {
    AwardsView()
}
