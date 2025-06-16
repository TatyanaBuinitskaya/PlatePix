//
//  MainSplitView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 30.04.2025.
//

import SwiftUI

/// The main split view layout of the app, organizing the sidebar, content, and detail views.
struct MainSplitView: View {
    /// The data controller that manages the app's data, including Core Data operations and cloud synchronization.
    @EnvironmentObject var dataController: DataController
    /// The color manager that keeps track of the selected theme color and updates the UI accordingly.
    @EnvironmentObject var colorManager: AppColorManager
    /// Shared user preferences for managing UI settings across the app.
    @EnvironmentObject var userPreferences: UserPreferences

    var body: some View {
        NavigationSplitView {
            SideBarView(dataController: dataController)
        } content: {
            ContentView()
                .environmentObject(userPreferences)
                .environmentObject(colorManager)
        } detail: {
            DetailView()
        }
    }
}

#Preview {
    MainSplitView()
        .environmentObject(DataController.preview)  // Add any required environment objects
        .environmentObject(AppColorManager())
        .environmentObject(UserPreferences())
}
