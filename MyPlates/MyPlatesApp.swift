//
//  MyPlatesApp.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//
import BackgroundTasks
import CoreSpotlight
import SwiftUI
import WidgetKit

/// The main entry point of the MyPlates application, responsible for initializing the app's environment and managing its lifecycle.
@main
struct MyPlatesApp: App {
    /// The data controller that manages the app's data, including Core Data operations and cloud synchronization.
    @StateObject var dataController = DataController()
    /// The current scene phase of the app, used to detect transitions between active, background, and inactive states.
    @Environment(\.scenePhase) var scenePhase
    /// Adapts `AppDelegate` for use with SwiftUI's application lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// The shared instance of user preferences, used to store UI settings persistently.
    @StateObject var userPreferences = UserPreferences.shared  // Create the shared instance
    /// A state variable that tracks whether a plate is opened via Spotlight search.
    /// When this is `true`, the UI updates to show the selected plate.
    @State private var openSpotlightPlate = false  // Track Spotlight navigation

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                /// The sidebar view of the app, providing navigation options for different sections.
                SideBarView(dataController: dataController)
            } content: {
                /// The main content view where the primary list of plates is displayed.
             //   ContentView(dataController: dataController)
                ContentView()
                    .environmentObject(userPreferences)  // Pass it down as EnvironmentObject
                // Detect changes to `openSpotlightPlate` and reset after handling.
                    .onChange(of: openSpotlightPlate) {
                        if openSpotlightPlate {
                            openSpotlightPlate = false
                        }
                    }
            } detail: {
                /// The detail view that shows specific information about a selected plate.
                DetailView()
            }
            // Injects the Core Data context into the environment, allowing views to access and modify persistent data.
            .environment(\.managedObjectContext, dataController.container.viewContext)
            // Injects the data controller into the environment, providing shared access to app-wide data operations.
            .environmentObject(dataController)
            // Saves data automatically when the app moves to the background or becomes inactive.
            .onChange(of: scenePhase) {
                if scenePhase != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }
// spotlight
//    func loadSpotlightItem(_ userActivity: NSUserActivity) {
//        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
//            dataController.selectedPlate = dataController.plate(with: uniqueIdentifier)
//            dataController.selectedFilter = .all
//        }
//    }
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
