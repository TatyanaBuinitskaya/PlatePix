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
            Button{
                // Clear the selected date without modifying the applied tag filter
                dataController.selectedDate = nil
                dataController.selectedFilter = .all
                // If no filter exists, ensure the default "All" filter is applied
//                if dataController.selectedFilter == nil {
//                    dataController.selectedFilter = Filter.all
//                }

                dismiss()
            } label: {
                Text("All plates")
                    .font(.title2)
            }
                   Text("Select a Date")
                        .fontWeight(.semibold)
                       .padding()

//                   DatePicker(
//                       "Select a Date",
//                       selection: Binding(
//                           $dataController.selectedDate,
//                           replacingNilWith: Date()
//                   //        dataController.selectedFilter = Filter.filterForDate($dataController.selectedDate)
//                       ),
//                       displayedComponents: [.date]
//                   )
//                   .datePickerStyle(GraphicalDatePickerStyle())
//                   .padding()
            
            DatePicker(
                "Select a Date",
                selection: Binding(
                    get: {
                        dataController.selectedDate ?? Date() // Default to today if no date is selected
                    },
                    set: { newDate in
                        // Update the selected date in the data controller
                        dataController.selectedDate = newDate

                        // Update the filter while preserving the tag
                        if var currentFilter = dataController.selectedFilter {
                            currentFilter.selectedDate = newDate // Update only the date
                            dataController.selectedFilter = currentFilter // Reassign to trigger UI updates
                        } else {
                            // If no filter exists, create a new one with the selected date
                            dataController.selectedFilter = Filter.filterForDate(newDate)
                        }
                    }
                ),
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()

                   if let selectedDate = dataController.selectedDate {
                       VStack{
                           Text("Selected Date: \(selectedDate, formatter: dateFormatter)")
                               .fontWeight(.semibold)
                           
                           Text("Plates: \(dataController.countSelectedDatePlates(for: selectedDate))")
                       }
                       .padding()
                   } else {
                       Text("No Date Selected")
                           .fontWeight(.semibold)
                           .padding()
                   }
            Button{
                dismiss()
            } label: {
                Text("Ok")
                    .font(.title2)
            }
           
               }
           }

           // A date formatter to display the selected date in a readable format.
           private var dateFormatter: DateFormatter {
               let formatter = DateFormatter()
               formatter.dateStyle = .medium
               return formatter
           }
}

//extension Binding {
//    init<T>(_ source: Binding<T?>, replacingNilWith defaultValue: T) where Value == T {
//        self.init(
//            get: { source.wrappedValue ?? defaultValue },
//            set: { newValue in source.wrappedValue = newValue }
//        )
//    }
//}

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
