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
            
            Text("You can become who you want")
           
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(dataController.platesForSelectedFilter()) { plate in
                        NavigationLink(value: plate){
                            PlateBox(plate: plate)
                        }
                    }
                }
                .padding(10)
                .searchable(text: $dataController.filterText, prompt: "Filter plates")
            }
        }
        .onChange(of: dataController.selectedFilter) {
            if dataController.selectedFilter == Filter.all || dataController.selectedFilter == Filter.today {
                dataController.selectedDate = nil
            }
        }
        .onChange(of: dataController.selectedDate) {
            if let date = dataController.selectedDate {
                if dataController.selectedFilter == Filter.today {
                    dataController.selectedFilter = Filter.all
                }
                dataController.selectedFilter?.minModificationDate = Calendar.current.startOfDay(for: date)
            }
        }
        .navigationTitle(dataController.dynamicTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading){
                if (dataController.selectedFilter?.quality ?? -1) >= 0 {} else {
                    Menu {
                        Picker("Meal Quality", selection: $dataController.filterQuality) {
                            Text("All").tag(-1)
                            Text("Unhealthy").tag(0)
                            Text("Moderate").tag(1)
                            Text("Healthy").tag(2)
                        }
                    } label: {
                        Image(systemName: "star.fill")
                            .foregroundColor(
                                dataController.filterQuality == 0 ? .red :
                                    dataController.filterQuality == 1 ? .yellow :
                                    dataController.filterQuality == 2 ? .green : .blue
                            )
                    }
                }
                    Menu {
                        Button("All"){
                            dataController.selectedFilter = .all
                        }
                        ForEach(tagFilters, id: \.self) { filter in
                            Button(action: {
                                dataController.selectedFilter = filter
                            }
                            ) {
                                Text(filter.name)
                            }
                        }
                    } label: {
                        Image(systemName: "fork.knife.circle") // Toolbar button
                    }
                
                Menu {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                    }
                    
                    Divider()
                    
                    Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                        Text("Newest to Oldest").tag(true)
                        Text("Oldest to Newest").tag(false)
                    }
                } label: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }

                    Button(action: {
                        showCalendarSheet = true
                    }) {
                        Image(systemName: "calendar")
                        
                    }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing){
                Button(action: {
                    dataController.newPlate()
                    isNewPlateCreated = true
                    
                }) {
                    Label("New Plate", systemImage: "square.and.pencil")
                }
                .padding()
                
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
        .navigationDestination(for: Plate.self) { plate in
            PlateView(plate: plate)
        }
        .navigationDestination(isPresented: $isNewPlateCreated) {
            if let newPlate = dataController.selectedPlate {
                PlateView(plate: newPlate)
            }
        }
        .navigationDestination(isPresented: $isNavigatingToSettings) {
            SettingsView()  // Destination for navigation
        }
        .sheet(isPresented: $showPDFSheet){
            PDFSheetShare()
        }
        .sheet(isPresented: $showCalendarSheet){
            CalendarSheetView()
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


