//
//  NoPlateIView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

/// A view displayed when no plate is selected.
struct NoPlateIView: View {
    /// The environment object that provides the shared data controller.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        // Displays a message indicating no plate is selected.
        Text("No Plate Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        // Provides a button that allows the user to create a new plate.
        Button("New Plate", action: dataController.newPlate)
    }
}

#Preview {
    NoPlateIView()
}
