//
//  SettingsView.swift
//  PlatePix
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
    /// URL for leaving a review on the App Store.
    private(set) var reviewLink = URL(string: "https://apps.apple.com/app/id6743003345?action=write-review")
    /// Support email configuration.
    @State private var email = SupportEmail(toAddress: "platepixapp@gmail.com",
                                            subject: "Support Email",
                                            messageHeader: "Please describe your issue or feature below")
    /// A variable that controls whether the home screen widget sheet is displayed.
    @State var showHomeScreenWidgetSheet: Bool = false
    /// A variable that controls whether the lock screen widget sheet is displayed.
    @State var showLockScreenWidgetSheet: Bool = false
    /// A state variable that determines whether the store view should be shown.
    @State private var showingStore = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    if !dataController.isSubscriptionIsActive {
                        // Premium
                        Button {
                            dataController.showStoreFromSettings = true
                            showingStore = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Free version allows up to 35 plates")
                                        .foregroundStyle(Color.white)
                                        .font(.body)
                                  
                                        Text("Get unlimited with Premium")
                                            .foregroundStyle(Color.white)
                                            .font(.title3)
                                            .fontDesign(.rounded)
                                            .fontWeight(.semibold)
                                    }
                            }
                            .contentShape(Rectangle())
                        }
                        .listRowBackground(LinearGradient(
                            gradient: Gradient(colors: [
                                Color("GirlsPink"),
                                Color("LavenderRaf")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom))
                        .sheet(isPresented: $showingStore, content: {
                            StoreView()}
                        )
                    }

                    // Section for UI customization settings.
                    Section("Personalization") {

                        // Allows user to choose a theme color
                        ColorPickerView()

                        // Button to open the reminders sheet.
                        Button {
                            showRemindersSheet = true
                        } label: {
                            HStack {
                                Label("Reminders", systemImage: "envelope")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }

                        // Button to open the app language settings.
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Label("Language", systemImage: "flag")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }

                        // Button to show the home screen widget settings.
                        Button {
                            showHomeScreenWidgetSheet.toggle()
                        } label: {
                            HStack {
                                Label("Home Screen Widget", systemImage: "quote.bubble")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .sheet(isPresented: $showHomeScreenWidgetSheet, content: {
                            HomeScreenWidgetView()
                        })

                        // Button to show the lock screen widget settings.
                        Button {
                            showLockScreenWidgetSheet.toggle()
                        } label: {
                            HStack {
                                Label("Lock Screen Widget", systemImage: "text.bubble")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .sheet(isPresented: $showLockScreenWidgetSheet, content: {
                            LockScreenWidgetView()
                        })
                    }

                    // Section containing app support, feedback, and legal information.
                    Section("About App") {

                        // Button to open the App Store review page.
                        Button {
                            if let link = reviewLink {
                                openURL(link)
                            }
                        } label: {
                            HStack {
                                Label("Leave a review", systemImage: "hand.thumbsup")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }

                        // Button to share the app link.
                        ShareLink(item: URL(string: "https://apps.apple.com/app/id6743003345")!) {
                            HStack {
                                Label("Share", systemImage: "square.and.arrow.up")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }

                        // Button to send a support email.
                        Button {
                            email.send(openURL: openURL)
                        } label: {
                            HStack {
                                Label("Contact us", systemImage: "at")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }

                        // Button to open the terms and conditions page.
                        Button {
                            if let urlTerms = URL(string: "https://tatyanabuinitskaya.github.io/PlatePixTerms/") {
                                openURL(urlTerms)
                            }
                        } label: {
                            HStack {
                                Label("Terms and conditions", systemImage: "doc.text")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        // Button to open the privacy policy page.
                        Button {
                            if let urlPolicy = URL(
                                string: "https://tatyanabuinitskaya.github.io/PlatePixPrivacyPolicy/"
                            ) {
                                openURL(urlPolicy)
                            }
                        } label: {
                            HStack {
                                Label("Privacy policy", systemImage: "shield")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                //  .accentColor(fallbackColorManager.selectedColor.color)
                .accentColor(colorManager.selectedColor.color)
                .sheet(isPresented: $showRemindersSheet) {
                    RemindersSheetView()
                        .presentationDetents([.fraction(0.4)])
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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

#Preview("English") {
    SettingsView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    SettingsView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
