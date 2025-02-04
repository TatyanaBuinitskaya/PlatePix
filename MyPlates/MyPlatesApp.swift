//
//  MyPlatesApp.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

/// The main entry point of the MyPlates application, responsible for initializing the app's environment and managing its lifecycle.
@main
struct MyPlatesApp: App {
    /// The data controller that manages the app's data, including Core Data operations and cloud synchronization.
    @StateObject var dataController = DataController()
    /// The current scene phase of the app, used to detect transitions between active, background, and inactive states.
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                /// The sidebar view of the app, providing navigation options for different sections.
                SideBarView()
            } content: {
                /// The main content view where the primary list of plates is displayed.
                ContentView()
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
        }
    }
}
