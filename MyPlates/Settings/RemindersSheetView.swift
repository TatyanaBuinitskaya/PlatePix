//
//  RemindersSheetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 10.02.2025.
//

import SwiftUI

/// A view that allows users to enable and configure meal reminders.
struct RemindersSheetView: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// The dismiss environment property to close the sheet view.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form{
            Section("Reminders") {
                /// Toggle switch to enable or disable reminders.
                /// Uses `.animation()` to smoothly show/hide the `DatePicker` when toggled.
                Toggle("Show reminders", isOn: $dataController.reminderEnabled.animation())
                    .sensoryFeedback(trigger: dataController.reminderEnabled) { oldValue, newValue in
                        newValue ? .success : .warning // Success haptic when enabling, warning when disabling
                            }
                /// If reminders are enabled, show the `DatePicker` to allow time selection.
                if dataController.reminderEnabled {
                    DatePicker(
                        "Reminder time",
                        selection: $dataController.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            Button("Ok"){
                dismiss()
            }
        }
    }
}

#Preview {
    RemindersSheetView()
}
