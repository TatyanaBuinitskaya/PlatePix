//
//  RemindersSheetView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 10.02.2025.
//

import SwiftUI

/// A view that allows users to enable and configure meal reminders.
struct RemindersSheetView: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The dismiss environment property to close the sheet view.
    @Environment(\.dismiss) var dismiss
    /// The environment property that rovides access to the environment's `openURL` action, used to open external links.
    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            Section("Reminders") {
                Toggle("Show", isOn: $dataController.reminderEnabled.animation())
                // If reminders are enabled, show the `DatePicker` to allow time selection.
                if dataController.reminderEnabled {
                    DatePicker(
                        "Time",
                        selection: $dataController.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("OK")
                        .font(.title2)
                        .padding(5)
                        .padding(.horizontal, 20)
                        .background(Capsule().fill(colorManager.selectedColor.color))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
        .alert("Notifications are not enabled", isPresented: $dataController.showingNotificationsError) {
            Button("Check Settings", action: showAppSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: dataController.reminderEnabled) {
            Task {
                    await dataController.updateReminder()
                }
        }
        .onChange(of: dataController.reminderTime) {
            Task {
                await dataController.updateReminder()
            }
        }
    }

    /// Opens app notification settings if there is an issue with reminders.
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }
}

#Preview("English") {
    RemindersSheetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}
#Preview("Russian") {
    RemindersSheetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
