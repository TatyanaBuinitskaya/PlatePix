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
    /// The environment property that rovides access to the environment's `openURL` action, used to open external links.
    @Environment(\.openURL) var openURL
    /// A variable that controls the visibility of the reminders sheet.
    @State var showRemindersSheet = false
    /// A variable that controls the display of a notifications-related error alert.
    @State private var showingNotificationsError = false
    // TODO: Add real MyPlates app ID !
    /// URL for leaving a review on the App Store.
    private(set) var reviewLink = URL(string: "https://apps.apple.com/app/id6499429063?action=write-review")
    // TODO: Add real email !
    /// Support email configuration.
    @State private var email = SupportEmail(toAddress: "elixir.mobileapp@gmail.com",
                                            subject: "Support Email",
                                            messageHeader: "Please describe your issue or feature below")
    /// A variable that controls whether the home screen widget sheet is displayed.
    @State var showHomeScreenWidgetSheet: Bool = false
    /// A variable that controls whether the lock screen widget sheet is displayed.
    @State var showLockScreenWidgetSheet: Bool = false

    var body: some View {
        NavigationView {
            List {
                // Section for UI customization settings.
                Section("Personalize") {

                    // Allows user to choose a theme color
                    ColorPickerView()

                    // Button to open the reminders sheet.
                    Button{
                        showRemindersSheet = true
                    } label: {
                        Label("Reminders", systemImage: "envelope")
                    }

                    // Button to open the app language settings.
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Language", systemImage: "flag")
                    }

                    // Button to show the home screen widget settings.
                    Button {
                        showHomeScreenWidgetSheet.toggle()
                    } label: {
                        Label("Home Screen Widget", systemImage: "quote.bubble")
                    }
                    .sheet(isPresented: $showHomeScreenWidgetSheet, content: {
                        HomeScreenWidgetView()
                    })

                    // Button to show the lock screen widget settings.
                    Button {
                        showLockScreenWidgetSheet.toggle()
                    } label: {
                        Label("Lock Screen Widget", systemImage: "text.bubble")
                    }
                    .sheet(isPresented: $showLockScreenWidgetSheet, content: {
                        LockScreenWidgetView()
                    })
                }

                // Section containing app support, feedback, and legal information.
                Section("About App") {
                    
                    // Button to open the App Store review page.
                    Button {
                        if let link = reviewLink{
                            openURL(link)
                        }
                    } label: {
                        Label("Leave a review", systemImage: "hand.thumbsup")
                    }

                    // TODO: Add real app MyPlates ID from AppStore !!!
                    // Button to share the app link.
                    ShareLink(item: URL(string: "https://apps.apple.com/app/id6499429063")!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    // Button to send a support email.
                    Button {
                        email.send(openURL: openURL)
                    } label: {
                        Label("Contact us", systemImage: "at")
                    }

                    // Button to open the terms and conditions page.
                    Button {
                        if let urlTerms = URL(string: "https://tatyanabuinitskaya.github.io/PlatePixTerms/") {
                            openURL(urlTerms)
                        }
                    } label: {
                        Label("Terms and conditions", systemImage: "doc.text")
                    }

                    // Button to open the privacy policy page.
                    Button {
                        if let urlPolicy = URL(string:  "https://tatyanabuinitskaya.github.io/PlatePixPrivacyPolicy/") {
                            openURL(urlPolicy)
                        }
                    } label: {
                        Label("Privacy policy", systemImage: "shield")
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
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
    
    /// Opens app notification settings if there is an issue with reminders.
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }

    /// Updates the reminder based on user settings.
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

