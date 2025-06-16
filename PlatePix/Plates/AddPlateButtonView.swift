//
//  AddPlateButtonView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 01.05.2025.
//

import SwiftUI

/// A button view  that triggers the creation of a new plate.
struct AddPlateButtonView: View {
    /// The data controller responsible for managing Core Data and related operations.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// A state variable that determines whether the store view should be shown.
    @Binding var showingStore: Bool
    /// An environment property that provides access to the system's request review action.
    /// This allows the app to prompt the user for a review at an appropriate time.
    @Environment(\.requestReview) var requestReview

    // TODO:
    var body: some View {
        Button {
            dataController.tryNewPlate()
            dataController.isNewPlateCreated = true // Marks that a new plate has been created.
          //  let counter = 0
            let counter = dataController.plateCount
            print("Counter updated: \(counter)")

            if counter == 15 || counter == 30 || counter.isMultiple(of: 300) {
                print("Requesting review")

                requestReview()
            }
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .foregroundStyle(.white)
                .padding(10)
                .background(Circle().fill(Color(colorManager.selectedColor.color)))
                .padding(2)
                .background(Circle().fill(.ultraThickMaterial))
        }
      //  .sheet(isPresented: $showingStore, content: StoreView.init)
    }
}

#Preview {
    AddPlateButtonView(showingStore: .constant(false))
        .environmentObject(DataController())
        .environmentObject(AppColorManager())
}
