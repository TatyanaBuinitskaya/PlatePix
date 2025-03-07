//
//  AwardSheetView.swift
//  PlatePix
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
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The constant size for the award image.
    private let imageSize: CGFloat = 100
    /// The padding applied to buttons for consistent spacing.
    private let buttonPadding: CGFloat = 15
    /// The corner radius applied to buttons for rounded edges.
    private let buttonCornerRadius: CGFloat = 8
    
    var body: some View {
        if let lastAward = dataController.congratulatedAwards.last {
            VStack(spacing: 10) {
                VStack {
                    HStack {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 60))
                            .scaleEffect(x: -1, y: 1)
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 60))
                    }
                    .padding(.vertical)
                    Text("Congratulations!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 250)
                .background(Color(colorManager.selectedColor.color).gradient)
                Spacer()
                Text("You've earned award:")
                    .font(.headline)
                    .padding()
                Text("\(lastAward.name)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                AwardIcon(award: lastAward, size: 125, color: Color(lastAward.color))
                Spacer()
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("OK")
                        .font(.title2)
                        .padding(5)
                        .padding(.horizontal, 20)
                        .background(Capsule().fill(Color(colorManager.selectedColor.color)))
                        .foregroundStyle(.white)
                }
                .padding()
                Spacer()
            }
        } else {
            // Fallback message when no awards are earned yet.
            Text("No awards earned yet")
                .font(.body)
                .foregroundStyle(.gray)
        }
    }
}

#Preview("English") {
    AwardSheetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    AwardSheetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
