//
//  SettingsView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 07.01.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Form {
                Section("Personalize") {
                    Label("Theme", systemImage: "paintpalette")
                    Label("Reminders", systemImage: "envelope")
                    Label("Language", systemImage: "flag")
                    Label("Home Screen Widget", systemImage: "quote.bubble")
                    Label("Lock Screen Widget", systemImage: "text.bubble")
                }
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
        .navigationBarBackButtonHidden(true) // Hide the default back button text (date or any unwanted text)
        .toolbar {
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
