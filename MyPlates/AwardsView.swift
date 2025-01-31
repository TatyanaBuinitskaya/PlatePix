//
//  AwardsView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 24.12.2024.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
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
    var awardTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }
    func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
}

#Preview {
    AwardsView()
}
