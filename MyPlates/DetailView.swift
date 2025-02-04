//
//  DetailView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI

/// A view that displays the details of a selected plate.
struct DetailView: View {
    /// The environment object that provides data for the selected plate.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            // Displays the PlateView if a plate is selected, otherwise shows the NoPlateIView.
            // The conditional ensures that the UI adapts based on whether a plate is selected.
            if let plate = dataController.selectedPlate {
                PlateView(plate: plate)
            } else {
                NoPlateIView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
        .environmentObject(DataController.preview)

}
