//
//  CalendarSheetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 08.01.2025.
//

import SwiftUI

struct CalendarSheetView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            headerSection
            datePickerSection
            selectedDateInfo
            okButton
        }
        .padding()
    }
    private var headerSection: some View {
        VStack(spacing: 16) {
            Button {
                dataController.selectedDate = nil
                dataController.selectedFilter = .all
                dismiss()
            } label: {
                Text("All Plates")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            Text("Select a Date")
                .font(.headline)
                .padding(.top)
        }
    }
    private var datePickerSection: some View {
        DatePicker(
            "Select a Date",
            selection: Binding(
                get: {
                    dataController.selectedDate ?? Date()
                },
                set: { newDate in
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
            } else {
                Text("No Date Selected")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
        }
    }

    private var okButton: some View {
        Button {
            dismiss()
        } label: {
            Text("OK")
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}

struct SelectedDateRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
}

extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = (newValue == defaultValue) ? nil : newValue
            }
        )
    }
}

#Preview {
    CalendarSheetView()
}
