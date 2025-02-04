//
//  SettingsView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 07.01.2025.
//

import SwiftUI

/// The settings screen that allows users to personalize app preferences and access app-related information.
struct SettingsView: View {
    /// The environment property used to dismiss the current view when the back button is tapped.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // A section that provides options to personalize the app's appearance and behavior.
                Section("Personalize") {
                    Label("Theme", systemImage: "paintpalette")
                    Label("Reminders", systemImage: "envelope")
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
        }
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
    }
}

#Preview {
    SettingsView()
}
