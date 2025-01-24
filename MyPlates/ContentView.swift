//
//  ContentView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "fork.knife.circle", tag: tag)
        }
    }
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    @State private var isNewPlateCreated = false
    @State private var isNavigatingToSettings = false
  
    @State private var showPDFSheet = false
    @State private var showCalendarSheet = false
    @State private var showFilterMenu = false
    
    
    var body: some View {
        //List right
        //                List(selection: $dataController.selectedPlate) {
        //                    ForEach(dataController.platesForSelectedFilter()) { plate in
        //                        PlateBox(plate: plate)
        //
        //                            }
        //                                        .onDelete(perform: delete)
        //                        }
        //                .listStyle(.plain)
        
        NavigationStack {
            ZStack{
                VStack{
                    Text("You can become who you want")
                    
                    ScrollView {
                        LazyVGrid(columns: columns
                              //    , spacing: 16
                        ) {
                            ForEach(dataController.platesForSelectedFilter()) { plate in
                                NavigationLink(value: plate){
                                    PlateBox(plate: plate)
                                }
                            }
                        }
                      //  .padding(5)
                        // 1 tag
                        .searchable(text: $dataController.filterText, prompt: "Filter plates")
                        // many tags
//                        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Filter plates, or type # to add tags") { tag in
//                            Text(tag.tagName)
//                        }
                     
                    }
                }
                .padding()
                VStack {
                    Spacer()
                    HStack {
                        HStack{
                            Text("time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button(action: {
                                dataController.showMealTime.toggle() // Toggle the state
                            }) {
                                Image(systemName: dataController.showMealTime ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            Text("quality")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button(action: {
                                dataController.showQuality.toggle() // Toggle the state
                            }) {
                                Image(systemName: dataController.showQuality ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            
                            
                            Text("notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button(action: {
                                dataController.showNotes.toggle()
                            }) {
                                Image(systemName: dataController.showNotes ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            Text("tags")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button(action: {
                                dataController.showTags.toggle() // Toggle the state
                            }) {
                                Image(systemName: dataController.showTags ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                        .padding(5)
                        .background{
                            Capsule()
                                .fill(Color.blue)
                        }
                        .padding()
                        
                        Spacer()
                        Button(action: {
                            dataController.newPlate()
                            isNewPlateCreated = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
                .navigationTitle(dataController.dynamicTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
//                    ToolbarItemGroup(placement: .navigationBarLeading){
//                        let filterOptions: [(label: String, filter: Filter)] = [
//                            ("All", .all),
//                            ("Healthy", .healthy),
//                            ("Moderate", .moderate),
//                            ("Unhealthy", .unhealthy)
//                        ]
//                        
//                        Menu {
//                            ForEach(filterOptions, id: \.filter) { option in
//                                Button {
//                                    dataController.selectedFilter = option.filter
//                                } label: {
//                                    HStack {
//                                        Text(option.label)
//                                        Spacer()
//                                        // Add checkmark if this filter is selected or if nothing is selected and the option is "All"
//                                        if dataController.selectedFilter == option.filter ||
//                                            (dataController.selectedFilter?.quality == -1 && option.filter == .all) {
//                                            Image(systemName: "checkmark")
//                                        }
//                                    }
//                                }
//                            }
//                        } label: {
//                            Image(systemName: dataController.selectedFilter?.quality == -1 ? "star" : "star.fill")
//                        }
//                        
//                        Menu {
//                            // "All" Button - Clears the selected tag filter, but keeps other filters (like date) intact
//                            Button(action: {
//                                // Clear the tag from the selected filter
//                                dataController.selectedFilter?.tag = nil
//                                
//                                // Reset the filter based on the selected date or "All" if no date is set
//                                if let selectedDate = dataController.selectedDate {
//                                    dataController.selectedFilter = Filter.filterForDate(selectedDate)
//                                } else {
//                                    dataController.selectedFilter = Filter.all
//                                }
//                                
//                            }
//                            ) {
//                                HStack {
//                                    Text("All")
//                                    Spacer()
//                                    
//                                    if dataController.selectedFilter?.tag == nil {
//                                        Image(systemName: "checkmark")
//                                    }
//                                }
//                            }
//                            
//                            ForEach(tagFilters, id: \.self) { filter in
//                                Button(action: {
//                                    dataController.selectedFilter = filter
//                                }) {
//                                    HStack {
//                                        Text(filter.name)
//                                        Spacer()
//                                        if dataController.selectedFilter?.tag == filter.tag {
//                                            Image(systemName: "checkmark")
//                                        }
//                                    }
//                                }
//                            }
//                        } label: {
//                            Image(systemName: dataController.selectedFilter?.tag == nil ? "fork.knife.circle" : "fork.knife.circle.fill")
//                        }
//                        
//                        
//                        Menu {
//                            Picker("Sort Order", selection: $dataController.sortNewestFirst) {
//                                Text("Newest to Oldest").tag(true)
//                                Text("Oldest to Newest").tag(false)
//                            }
//                        } label: {
//                            Label("Sort by", systemImage: "arrow.up.arrow.down")
//                        }
//                        
//                        Button(action: {
//                            showCalendarSheet = true
//                        }) {
//                            Image(systemName: dataController.selectedDate == nil ? "calendar" : "calendar.circle.fill")
//                            
//                        }
//                    }
                    
//                    ToolbarItem(placement: .navigationBarLeading) {
//                       
//                        Menu{
//                            Section {
//                                Button(action: {
//                                    showCalendarSheet = true
//                                }) {
//                                    HStack {
//                                        Text("Select Date")
//                                        Spacer()
//                                        Image(systemName: dataController.selectedDate == nil ? "calendar" : "calendar.circle.fill")
//                                    }
//                                }
//                                
//                            }
//                            // Quality Filter Options
//                            Section {
//                                Label("Quality", systemImage: dataController.selectedFilter?.quality == -1 ? "star" : "star.fill")
//                                    .font(.caption)
//                                let filterOptions: [(label: String, filter: Filter)] = [
//                                    ("All", .all),
//                                    ("Healthy", .healthy),
//                                    ("Moderate", .moderate),
//                                    ("Unhealthy", .unhealthy)
//                                ]
//                                
//                                ForEach(filterOptions, id: \.filter) { option in
//                                    Button {
//                                        dataController.selectedFilter = option.filter
//                                    } label: {
//                                        HStack {
//                                            Text(option.label)
//                                            Spacer()
//                                            if dataController.selectedFilter == option.filter ||
//                                                (dataController.selectedFilter?.quality == -1 && option.filter == .all) {
//                                                Image(systemName: "checkmark")
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            //if mealtime not tags:
////                            Section {
////                                Label("Mealtime", systemImage: dataController.selectedFilter?.mealtime == nil ? "clock" : "clock.fill")
////                                    .font(.caption)
////                                let filterOptions: [(label: String, filter: Filter)] = [
////                                    ("All", .all),
////                                    ("Breakfast", .breakfast),
////                                    ("Morning snack", .morningSnack),
////                                    ("Day snack", .daySnack),
////                                    ("Dinner", .dinner),
////                                    ("Evening snack", .eveningSnack),
////                                    ("Extra meal", .extraMeal)
////                                    
////                                ]
////                                
////                                ForEach(filterOptions, id: \.filter) { option in
////                                    Button {
////                                        dataController.selectedFilter = option.filter
////                                    } label: {
////                                        HStack {
////                                            Text(option.label)
////                                            Spacer()
////                                            if dataController.selectedFilter == option.filter ||
////                                                (dataController.selectedFilter?.quality == nil && option.filter == .all) {
////                                                Image(systemName: "checkmark")
////                                            }
////                                        }
////                                    }
////                                }
////                            }
//                            
//                            // Tag Filter Options
//                            Section {
//                               
//                               Label("Tags", systemImage: dataController.selectedFilter?.tag == nil ? "fork.knife.circle" : "fork.knife.circle.fill")
//                            
//                                Button(action: {
//                                    dataController.selectedFilter?.tag = nil
//                                    if let selectedDate = dataController.selectedDate {
//                                        dataController.selectedFilter = Filter.filterForDate(selectedDate)
//                                    } else {
//                                        dataController.selectedFilter = Filter.all
//                                    }
//                                }) {
//                                    HStack {
//                                        Text("All")
//                                        Spacer()
//                                        if dataController.selectedFilter?.tag == nil {
//                                            HStack{
//                                                Image(systemName: "checkmark")
//                                               
//                                            }
//                                        }
//                                    }
//                                }
//                                
//                                ForEach(tagFilters, id: \.self) { filter in
//                                    Button(action: {
//                                        dataController.selectedFilter = filter
//                                    }) {
//                                        HStack {
//                                            Text(filter.name)
//                                            Spacer()
//                                            if dataController.selectedFilter?.tag == filter.tag {
//                                                Image(systemName: "checkmark")
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            Section {
//                               // Label("Sort order", systemImage: "arrow.up.arrow.down")
//                                Button(action: {
//                                    dataController.sortNewestFirst = true
//                                }) {
//                                    HStack {
//                                        Text("Newest to Oldest")
//                                        Spacer()
//                                        if dataController.sortNewestFirst {
//                                            Image(systemName: "checkmark")
//                                        }
//                                    }
//                                }
//                                
//                                Button(action: {
//                                    dataController.sortNewestFirst = false
//                                }) {
//                                    HStack {
//                                        Text("Oldest to Newest")
//                                        Spacer()
//                                        if !dataController.sortNewestFirst {
//                                            Image(systemName: "checkmark")
//                                        }
//                                    }
//                                }
//                            }
//                        } label: {
//                        Label("Filters", systemImage: dataController.selectedFilter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
//                    }
//                       
//                        
//                            
//                        
//                       
//                          
//                    }
                    
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing){
                        
                        Button(action: {
                            showPDFSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                            
                        }
                        
                        Button(action: {
                            isNavigatingToSettings = true
                        }) {
                            Image(systemName: "gear")
                            
                        }
                    }
         
            }
        }
        .navigationDestination(for: Plate.self) { plate in
            PlateView(plate: plate)
        }
        .navigationDestination(isPresented: $isNewPlateCreated) {
            if let newPlate = dataController.selectedPlate {
                PlateView(plate: newPlate)
            }
        }
        .navigationDestination(isPresented: $isNavigatingToSettings) {
            SettingsView()  
        }
        .sheet(isPresented: $showPDFSheet){
            PDFSheetShareView()
        }
        .sheet(isPresented: $showCalendarSheet){
            CalendarSheetView()
        }
       
                           
                        
        
        
        .onChange(of: dataController.selectedDate) {
            if let date = dataController.selectedDate{
                // If a date is selected, keep the existing filters (quality and tag) and add the date filter
                if let currentFilter = dataController.selectedFilter {
                    // If there's already a quality or tag filter, combine them with the date filter
                    if currentFilter.quality >= 0 || currentFilter.tag != nil {
                        dataController.selectedFilter = Filter.filterForDate(date).applyingFilters(from: currentFilter)
                    } else {
                        // If no other filters are selected, just apply the date filter
                        dataController.selectedFilter = Filter.filterForDate(date)
                    }
                }
            } else {
                // If no date is selected, apply the existing filters (quality/tag, etc.)
                if let currentFilter = dataController.selectedFilter {
                    dataController.selectedFilter = currentFilter
                } else {
                    dataController.selectedFilter = .all
                }
            }
        }
    }


    func delete(_ offsets: IndexSet) {
        let plates = dataController.platesForSelectedFilter()
        
        for offset in offsets {
            let item = plates[offset]
            dataController.delete(item)
        }
    }
}
    
    
#Preview {
    ContentView()
        .environmentObject(DataController.preview)

}


