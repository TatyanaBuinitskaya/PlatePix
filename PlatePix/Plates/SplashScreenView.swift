//
//  SplashScreenView.swift
//  PlatePix
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
    /// The shared instance of user preferences, used to store UI settings persistently.
    @StateObject var userPreferences = UserPreferences.shared  // Create the shared instance
    /// A state variable that determines when to transition from the splash screen.
    @State private var isActive = false
    /// A state variable that tracks whether a plate is opened via Spotlight search.
    /// When this is `true`, the UI updates to show the selected plate.
    @State private var openSpotlightPlate = false  // Track Spotlight navigation
    /// Controls the animation state.
    @State var animationState = false

    var body: some View {
        if isActive {
            /// The main content view where the primary list of plates is displayed.
            ContentView() // Your main app view
                .navigationBarHidden(false)
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
                LinearGradient(colors: [Color("LavenderRaf"), Color("GirlsPink")], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("PlatePix")
                        .font(.system(size: 50, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)

                    Text("Track Your Meals and Lose Weight, Stay Motivated and Improve Your Health!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Spacer()
                    Spacer()
                }
                .padding()
                .opacity(animationState ? 1 : 0)
                .scaleEffect(animationState ? 1 : 0.8)
                .animation(.easeOut(duration: 1), value: animationState)
                .onAppear {
                    animationState = true
                }
            }
            .navigationBarTitle("", displayMode: .inline) // Hide title
            .navigationBarHidden(true) // Hide navigation bar completely
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

#Preview("English") {
    SplashScreenView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    SplashScreenView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
