//
//  AppView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 30.04.2025.
//

import SwiftUI
import RevenueCat

/// The root view of the PlatePix app, managing app state, dependencies, and transitions between splash and main UI.
struct AppView: View {
    /// The data controller that manages the app's data, including Core Data operations and cloud synchronization.
    @StateObject var dataController = DataController()
    /// The color manager that keeps track of the selected theme color and updates the UI accordingly.
    @StateObject var colorManager = AppColorManager()
    /// Shared user preferences used across the app for persisting UI settings.
    @StateObject var userPreferences = UserPreferences.shared
    /// Tracks the current scene phase (active, background, inactive) to handle lifecycle events.
    @Environment(\.scenePhase) var scenePhase
    /// The color manager that keeps track of the selected theme color and updates the UI accordingly.
    @State private var showMainApp = false

    var body: some View {
        Group {
            if showMainApp {
                MainSplitView()
                    .environmentObject(dataController)
                    .environmentObject(colorManager)
                    .environmentObject(userPreferences)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .tint(colorManager.selectedColor.color)
                    .onChange(of: scenePhase) {
                        if scenePhase != .active {
                            dataController.save()
                        }
                    }
                    .onAppear {
                        Task {
                            await dataController.updateReminder()
                        }
                    }
            } else {
                SplashScreenView(showMainApp: $showMainApp)
            }
        }
    }
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_XivMTqpJYjMYwMHtKPZXIipMuMP")
    }
}

#Preview {
    AppView()
}
