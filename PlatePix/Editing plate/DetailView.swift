//
//  DetailView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI

/// A view that displays the details of a selected plate.
struct DetailView: View {
    /// The environment object that provides data for the selected plate.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
  
    var body: some View {
        VStack {
            if dataController.path.isEmpty {
                       NoPlateIView()
                  }
        }
        .navigationTitle("Plate Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("English") {
    
    DetailView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    DetailView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
