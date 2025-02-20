//
//  SplashScreenView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.02.2025.
//

import CoreSpotlight
import SwiftUI

/// A view that displays a splash screen before transitioning to the main content.
/// This screen is shown briefly when the app launches.
struct SplashScreenView: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// A state variable that determines when to transition from the splash screen.
    @State private var isActive = false
    /// The shared instance of user preferences, used to store UI settings persistently.
    @StateObject var userPreferences = UserPreferences.shared  // Create the shared instance
    /// A state variable that tracks whether a plate is opened via Spotlight search.
    /// When this is `true`, the UI updates to show the selected plate.
    @State private var openSpotlightPlate = false  // Track Spotlight navigation

    var body: some View {
        if isActive {
            /// The main content view where the primary list of plates is displayed.
            ContentView() // Your main app view
                .environmentObject(userPreferences)  // Pass it down as EnvironmentObject
                // Detect changes to `openSpotlightPlate` and reset after handling.
                .onChange(of: openSpotlightPlate) {
                    if openSpotlightPlate {
                        openSpotlightPlate = false
                    }
                }
                .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        } else {
            ZStack {
                Color("LavenderRaf") // Background color
                    .ignoresSafeArea()
                VStack{
                    Spacer()
                    Text("PlatePix")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    Text("Snap, save, and relive your daily plates!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                    Image("Logo") // Replace with your logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    Spacer()
                    Spacer()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }

    /// Handles Spotlight search selection.
        ///
        /// - Parameter userActivity: The user activity that triggered the app from Spotlight search.
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        // Retrieve the unique identifier stored in Spotlight's metadata.
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            // Find the corresponding plate in Core Data.
            if let plate = dataController.plate(with: uniqueIdentifier) {
                dataController.selectedPlate = plate
                openSpotlightPlate = true  // Trigger UI update
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
