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
    @EnvironmentObject var userPreferences: UserPreferences
    /// The color manager that keeps track of the selected theme color and updates the UI accordingly.
    @EnvironmentObject var colorManager: AppColorManager
    /// A state variable that tracks whether a plate is opened via Spotlight search.
    /// When this is `true`, the UI updates to show the selected plate.
    @State private var openSpotlightPlate = false  // Track Spotlight navigation
    /// Controls the animation state.
    @State var animationState = false
    /// A binding that determines whether the main application interface should be shown.
    @Binding var showMainApp: Bool

    var body: some View {
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
            .navigationBarTitle("", displayMode: .inline) // Hide title
            .navigationBarHidden(true) // Hide navigation bar completely
            .onAppear {
                        animationState = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showMainApp = true
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

struct SplashScreenPreviewWrapper: View {
    @State private var showMainApp = false

    var body: some View {
        SplashScreenView(showMainApp: $showMainApp)
            .environmentObject(DataController.preview)
            .environmentObject(AppColorManager())
    }
}

#Preview("English") {
    SplashScreenPreviewWrapper()
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Russian") {
    SplashScreenPreviewWrapper()
        .environment(\.locale, .init(identifier: "ru"))
}
