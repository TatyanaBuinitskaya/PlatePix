//
//  AwardSheetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 04.01.2025.
//

import SwiftUI

/// A view that displays congratulatory content when a user earns an award.
struct AwardSheetView: View {
    /// The data controller managing awards and application state.
    @EnvironmentObject var dataController: DataController
    /// The dismiss environment property to close the sheet view.
    @Environment(\.dismiss) var dismiss
    /// The constant size for the award image.
    private let imageSize: CGFloat = 100
    /// The padding applied to buttons for consistent spacing.
    private let buttonPadding: CGFloat = 15
    /// The corner radius applied to buttons for rounded edges.
    private let buttonCornerRadius: CGFloat = 8

    var body: some View {
        VStack(spacing: 20) {
            Text("Congratulations!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            Text("You've earned the following awards:")
                .padding(.horizontal)
            if let lastAward = dataController.congratulatedAwards.last {
                // Display the most recently earned award.
                awardContent(for: lastAward)
            } else {
                // Fallback message when no awards are earned yet.
                Text("No awards earned yet.")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }

    /// Creates and displays the content for a specific award.
       /// - Parameter award: The award to display.
    @ViewBuilder
    private func awardContent(for award: Award) -> some View {
        VStack {
            Text("\(award.name) Award!")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom)
            Image(systemName: award.image)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .padding(.bottom)
            Text("\(award.value)")
                .font(.title3)
                .foregroundColor(.secondary)
            Button {
                // Dismisses the award sheet and updates the data controller state.
                dataController.showCongratulations = false
                dismiss()
            } label: {
                Text("OK")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(buttonCornerRadius)
                    .padding(.top, 15)
                    .padding()
            }
            .accessibilityLabel("Dismiss award details")
        }
    }
}

#Preview {
    AwardSheetView()
}
