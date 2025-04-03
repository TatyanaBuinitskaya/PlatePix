//
//  NoPlateIView.swift
//  PlatePix
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
        Text("Select or Create a New Plate")
            .font(.title)
            .foregroundStyle(.secondary)
    }
}

#Preview("English") {
    NoPlateIView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    NoPlateIView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
