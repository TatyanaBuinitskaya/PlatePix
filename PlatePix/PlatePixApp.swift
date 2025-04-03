//
//  PlatePixApp.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import CoreSpotlight
import RevenueCat
import SwiftUI
import WidgetKit

/// The main entry point of the PlatePix application, responsible for initializing the app's environment and managing its lifecycle.
@main
struct PlatePixApp: App {
    /// The data controller that manages the app's data, including Core Data operations and cloud synchronization.
    @StateObject var dataController = DataController()
    /// The current scene phase of the app, used to detect transitions between active, background, and inactive states.
    @Environment(\.scenePhase) var scenePhase
    /// Adapts `AppDelegate` for use with SwiftUI's application lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// The color manager that keeps track of the selected theme color and updates the UI accordingly.
    @StateObject var colorManager = AppColorManager()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                /// The sidebar view of the app, providing navigation options for different sections.
                SideBarView(dataController: dataController)
            } content: {
             //   ContentView()
                SplashScreenView()
            } detail: {
                /// The detail view that shows specific information about a selected plate.
                DetailView()
                
            }
            // Injects the Core Data context into the environment, allowing views to access and modify persistent data.
            .environment(\.managedObjectContext, dataController.container.viewContext)
            // Injects the data controller into the environment, providing shared access to app-wide data operations.
            .environmentObject(dataController)
            .environmentObject(colorManager)
            .tint(colorManager.selectedColor.color)
            // Saves data automatically when the app moves to the background or becomes inactive.
            .onChange(of: scenePhase) {
                if scenePhase != .active {
                    dataController.save()
                }
            }
        }
    }

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_XivMTqpJYjMYwMHtKPZXIipMuMP")
    }
}
