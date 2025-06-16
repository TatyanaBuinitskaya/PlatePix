//
//  NoPlateIView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

/// A view displayed when no plate is selected.
struct NoPlateIView: View {
    /// The data controller responsible for managing Core Data and related operations.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager

    var body: some View {
        VStack {
            Spacer()
            Text("No Plate Selected")
                .font(.title)
                .foregroundStyle(.secondary)
                .padding()
            Text("Tap the '+' in the bottom right to add a new plate.")
                .font(.title3)
                .multilineTextAlignment(.center)
            Text("All created plates appear in the sidebar on the left, where you can select any of them to view or edit.")
                .font(.title3)
                .multilineTextAlignment(.center)
            Spacer()
            HStack {
                Spacer()
                AddPlateButtonView(showingStore: $dataController.showingStore)
                    .environmentObject(dataController)
                    .environmentObject(colorManager)
                    .accessibilityIdentifier("New Plate")
            }
         //   .sheet(isPresented: $dataController.showingStore, content: StoreView.init)
        }
        .padding()
    }
}

#Preview("English") {
    NoPlateIView()
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    NoPlateIView()
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
