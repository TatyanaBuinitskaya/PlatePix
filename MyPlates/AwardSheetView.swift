//
//  AwardSheetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 04.01.2025.
//

import SwiftUI

struct AwardSheetView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    private let imageSize: CGFloat = 100
    private let buttonPadding: CGFloat = 15
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
                awardContent(for: lastAward)
            } else {
                Text("No awards earned yet.")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
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
