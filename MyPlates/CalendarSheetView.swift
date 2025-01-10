//
//  CalendarSheetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 08.01.2025.
//

import SwiftUI

struct CalendarSheetView: View {
    @EnvironmentObject var dataController: DataController
    @Environment (\.dismiss) var dismiss
   
    var body: some View {
        VStack {
            Button("All plates"){
                dataController.selectedDate = nil
                dataController.selectedFilter = Filter.all
                dismiss()
            }
                   Text("Select a Date")
                       .font(.title)
                       .padding()

                   DatePicker(
                       "Select a Date",
                       selection: Binding(
                           $dataController.selectedDate,
                           replacingNilWith: Date()
                       ),
                       displayedComponents: [.date]
                   )
                   .datePickerStyle(GraphicalDatePickerStyle())
                   .padding()

                   if let selectedDate = dataController.selectedDate {
                     
                       Text("Selected Date: \(selectedDate, formatter: dateFormatter)")
                           .padding()
                   } else {
                       Text("No Date Selected")
                           .padding()
                   }
            Button("Ok"){
                dismiss()
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

extension Binding {
    init<T>(_ source: Binding<T?>, replacingNilWith defaultValue: T) where Value == T {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}

#Preview {
    CalendarSheetView()
}
