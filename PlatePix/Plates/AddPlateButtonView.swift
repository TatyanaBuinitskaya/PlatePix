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
            if let plate = dataController.newPlate() {
                dataController.path.append(plate)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataController.showingStore = true
                }
            }

            let counter = dataController.plateCount
            print("Counter updated: \(counter)")

            if counter == 8 || counter == 30 || counter.isMultiple(of: 300) {
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

    return AddPlateButtonView(
        showingStore: .constant(false)
    )
    .environmentObject(DataController())
    .environmentObject(AppColorManager())
}
