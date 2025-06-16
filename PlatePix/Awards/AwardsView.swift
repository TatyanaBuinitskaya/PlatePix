//
//  AwardsView.swift
//  PlatePix
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
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
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
                                AwardIcon(award: award, size: 85, color: color(for: award))

                                Text(award.name)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .foregroundStyle(color(for: award))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }

    /// The title for the award details alert, indicating whether the award is unlocked.
    var awardTitle: LocalizedStringKey {
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
        dataController.hasEarned(award: award) ? Color(award.color) : Color("GrayMaterial")
    }

    /// Provides an accessibility label for an award, indicating its status.
    /// - Parameter award: The award to generate the label for.
    /// - Returns: A `LocalizedStringKey` describing the award status.
    func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
}

#Preview("English") {
    AwardsView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    AwardsView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
