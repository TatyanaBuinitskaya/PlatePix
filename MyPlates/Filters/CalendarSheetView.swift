//
//  CalendarSheetView.swift
//  MyPlates
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
        VStack(spacing: 16) {
            Button {
                // Resets the date selection and filter, then dismisses the view.
                dataController.selectedDate = nil
                dataController.selectedFilter = .all
                dismiss()
            } label: {
                Text("All Plates")
                    .font(.title2)
            }
            
            Text("Select a Date")
                .font(.headline)
                .padding(.top)
        }
        .accentColor(colorManager.selectedColor.color)
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
                    SelectedDateRow(
                        label: "Selected Date:",
                        value: dataController.formattedDate(selectedDate) // Format the date explicitly
                    )
                    SelectedDateRow(
                        label: "Plates:",
                        value: "\(dataController.countSelectedDatePlates(for: selectedDate))"
                    )
                }
                .accentColor(colorManager.selectedColor.color)
            } else {
                // Displays a message when no date is selected.
                Text("No Date Selected")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.top)
            }
        }
        
    }

    /// The button to confirm the selection and dismiss the calendar sheet.
    private var okButton: some View {
        Button {
            // Dismisses the calendar sheet view.
            dismiss()
        } label: {
            Text("OK")
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(colorManager.selectedColor.color)
                .foregroundStyle(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}

/// A view representing a row that displays a label and its corresponding value.
struct SelectedDateRow: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The label describing the value.
    let label: String
    /// The value associated with the label.
    let value: String
    

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundStyle(colorManager.selectedColor.color)
        }
        .padding(.horizontal)
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

#Preview {
    CalendarSheetView()
}
