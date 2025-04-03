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

    var body: some View {
        Form {
            Section("Motivational Reminders") {
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
