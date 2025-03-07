//
//  CalendarSheetView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 08.01.2025.
//

import SwiftUI

/// A view that presents a calendar sheet allowing the user to select a date and filter data accordingly.
struct CalendarSheetView: View {
    /// The data controller that manages the application's data and state.
    @EnvironmentObject var dataController: DataController
    /// An environment variable used to dismiss the current view.
    @Environment(\.dismiss) var dismiss
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager

    var body: some View {
        VStack {
            headerSection
            datePickerSection
            selectedDateInfo
            okButton
        }
        .accentColor(colorManager.selectedColor.color)
        .padding()
    }

    /// The header section containing navigation and title elements.
    private var headerSection: some View {
        VStack() {
            Text("Select a Date:")
                .font(.headline)
                .padding(.top)
        }
    }

    /// A section displaying the graphical date picker for selecting a date.
    private var datePickerSection: some View {
        DatePicker(
            "Select a Date",
            selection: Binding(
                get: {
                    dataController.selectedDate ?? Date()
                },
                set: { newDate in
                    // Updates the selected date and applies the corresponding filter.
                    dataController.selectedDate = newDate
                    if let currentFilter = dataController.selectedFilter {
                        var updatedFilter = currentFilter
                        updatedFilter.selectedDate = newDate
                        dataController.selectedFilter = updatedFilter
                    } else {
                        dataController.selectedFilter = Filter.filterForDate(newDate)
                    }
                }
            ),
            displayedComponents: [.date]
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .padding()
    }

    /// Displays information about the selected date, including the formatted date and plate count.
    private var selectedDateInfo: some View {
        Group {
            if let selectedDate = dataController.selectedDate {
                VStack {
                    HStack{
                        Text("Selected Date: ")
                        Text(dataController.formattedDate(selectedDate))
                            .font(.headline)
                    }
                    Text("\(dataController.countSelectedDatePlates(for: selectedDate)) plates")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            } else {
                // Displays a message when no date is selected.
                Text("No Date Selected")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
        }
        
    }

    /// The button to confirm the selection and dismiss the calendar sheet.
    private var okButton: some View {
        Button {
            if let selectedDate = dataController.selectedDate {
                      dataController.selectedDate = nil
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                          dataController.selectedDate = selectedDate
                      }
                  }
            // Dismisses the calendar sheet view
            dismiss()
        } label: {
            Text("OK")
                .font(.title2)
                .padding(5)
                .padding(.horizontal, 20)
              //  .frame(maxWidth: .infinity)
                .background(Capsule().fill(colorManager.selectedColor.color))
                .foregroundStyle(.white)
               
        }
        .padding()
    }
}

/// An extension to `Binding` providing an initializer that replaces `nil` values with a default.
extension Binding where Value: Equatable {
    /// Initializes a binding that replaces `nil` values with a default value.
    /// - Parameters:
    ///   - source: The optional binding source.
    ///   - defaultValue: The default value to use when the source is `nil`.
    init(_ source: Binding<Value?>, replacingNilWith defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                // Converts the default value back to `nil` when unselected.
                source.wrappedValue = (newValue == defaultValue) ? nil : newValue
            }
        )
    }
}

#Preview("English") {
    CalendarSheetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
        }

#Preview("Russian") {
    CalendarSheetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
        }
