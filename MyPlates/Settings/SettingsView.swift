//
//  SettingsView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 07.01.2025.
//

import SwiftUI

/// The settings screen that allows users to personalize app preferences and access app-related information.
struct SettingsView: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The environment property used to dismiss the current view when the back button is tapped.
    @Environment(\.dismiss) var dismiss
    @State var showRemindersSheet = false
    @State private var showingNotificationsError = false
    @Environment(\.openURL) var openURL

  

    var body: some View {
        NavigationView {
            List {
                Section("Personalize") {
                    ColorPickerView()
                    
                    Button{
                        showRemindersSheet = true
                    } label: {
                        Label("Reminders", systemImage: "envelope")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Label("Language", systemImage: "flag")
                    Label("Home Screen Widget", systemImage: "quote.bubble")
                    Label("Lock Screen Widget", systemImage: "text.bubble")
                }
                // A section containing options related to app support, legal information, and feedback.
                Section("About App") {
                    Label("Leave a review", systemImage: "hand.thumbsup")
                    
                    Label("Share", systemImage: "square.and.arrow.up")
                    Label("Contact us", systemImage: "at")
                    Label("Restore purchases", systemImage: "arrow.circlepath")
                    Label("Terms and conditions", systemImage: "doc.text")
                    Label("Privacy policy", systemImage: "shield")
                }
               
            }
            .sheet(isPresented: $showRemindersSheet) {
                RemindersSheetView()
                    .presentationDetents([.medium])
                    .presentationDetents([.fraction(0.3)])
            }
        }
        .accentColor(colorManager.selectedColor.color)
        .navigationTitle("Settings")
        .navigationBarBackButtonHidden(true) // Hide the default back button text 
        .toolbar {
            // Adds a custom back button to the navigation bar for dismissing the settings view.
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "chevron.backward") // Custom back button title
                }
            }
        }
        .alert("Oops!", isPresented: $showingNotificationsError) {
            Button("Check Settings", action: showAppSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: dataController.reminderEnabled) {
            updateReminder()
        }
        .onChange(of: dataController.reminderTime) {
            updateReminder()
        }
    }
       
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }

    func updateReminder() {
        dataController.removeReminders()

        Task { @MainActor in
            if dataController.reminderEnabled {
                let success = await dataController.addReminder()

                if success == false {
                    dataController.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }

}

#Preview {
    SettingsView()
}

