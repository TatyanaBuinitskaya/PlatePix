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
    /// A variable that controls the visibility of the reminders sheet.
    @State var showRemindersSheet = false
    /// A variable that controls the display of a notifications-related error alert.
    @State private var showingNotificationsError = false
    /// The environment property that rovides access to the environment's `openURL` action, used to open external links.
    @Environment(\.openURL) var openURL
    // TODO: Add real MyPlates app ID !
    private(set) var reviewLink = URL(string: "https://apps.apple.com/app/id6499429063?action=write-review")
    // TODO: Add real email !
    @State private var email = SupportEmail(toAddress: "elixir.mobileapp@gmail.com",
                                     subject: "Support Email",
                                     messageHeader: "Please describe your issue or feature below")
  

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
                
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Language", systemImage: "flag")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Label("Home Screen Widget", systemImage: "quote.bubble")
                    Label("Lock Screen Widget", systemImage: "text.bubble")
                }
                // A section containing options related to app support, legal information, and feedback.
                Section("About App") {

                    Button {
                        if let link = reviewLink{
                            openURL(link)
                        }
                    } label: {
                        Label("Leave a review", systemImage: "hand.thumbsup")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // TODO: Add real app MyPlates ID from AppStore !!!
                    ShareLink(item: URL(string: "https://apps.apple.com/app/id6499429063")!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        email.send(openURL: openURL)
                    } label: {
                        Label("Contact us", systemImage: "at")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
//                        Purchases.shared.restorePurchases {(customerInfo, error) in
//                    // check customerInfo to see if entitlement is now active
//                        userViewModel.isSubscriptionIsActive = customerInfo?.entitlements.all["Premium"]?.isActive == true
                        } label: {
                            Label("Restore purchases", systemImage: "arrow.circlepath")
                        }
                        .buttonStyle(PlainButtonStyle())

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

