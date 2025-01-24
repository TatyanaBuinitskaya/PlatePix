//
//  SideBarView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI


struct SideBarView: View {
    @EnvironmentObject var dataController: DataController
  //  let smartFilters: [Filter] = [.all, .filterForDate(Date())] // Smart filters: "All" and "Today"
    let qualityFilters: [Filter] = [.healthy, .moderate, .unhealthy]
    //if mealtime not tags:
    let mealtimeFilters: [Filter] = [.breakfast, .morningSnack, .lunch, .daySnack, .dinner, .eveningSnack, .anytimeMeal]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }

    
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    
    @State private var showingAwards = false
    @State private var showCalendarSheet = false
    @State private var showTagFilterList = false
    @State private var showMealtimeFilterList = false
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Date Filters") {
                Button {
                    dataController.selectedFilter = Filter.all
                    dataController.selectedDate = nil
                } label: {
                    HStack{
                        Label("All plates", systemImage: "calendar")
                        Spacer()
                        Text("\(dataController.allPlatesCount)")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                
                Button {
                    dataController.selectedFilter = Filter.filterForDate(Date())
                    dataController.selectedDate = Date()
                } label: {
                    HStack{
                        Label("Today", systemImage: "1.square")
                        Spacer()
                        let date = dataController.selectedDate ?? Date()
                        Text("\(dataController.countSelectedDatePlates(for: date))")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                
                Button {
                    showCalendarSheet = true
                } label: {
                    HStack{
                        Label("Select date", systemImage: "calendar.badge.plus")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
            }
            
            Section("Tags") {
                
                
                //                Menu {
                //                    ForEach(tagFilters) { filter in
                //                        let plateCount = String(dataController.countTagPlates(for: filter.name))
                //                        NavigationLink(value: filter) {
                //                            HStack {
                //                                Text(filter.name + " " + plateCount)
                //                                Spacer()
                //                            }
                //                        }
                //                    }
                //                } label: {
                //                    HStack {
                //                        Image(systemName: "tag")
                //                        Text("Choose a Food tag filter")
                //                            .foregroundColor(.primary)
                //                        Spacer()
                //                        Image(systemName: "chevron.down")
                //
                //                    }
                //                }
                //            }
                Button{
                    withAnimation {
                        showTagFilterList.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(.blue)
                        Text("Choose a Food tag filter")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showTagFilterList ? 180 : 0)) // Rotate arrow based on state
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .animation(.easeInOut(duration: 0.3), value: showTagFilterList)
                    }
                }
                if showTagFilterList {
                    
                    ForEach(tagFilters) { filter in
                        NavigationLink(value: filter){
                            HStack {
                                Text(filter.name)
                                Spacer()
                                Text("\(dataController.countTagPlates(for: filter.name))")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showTagFilterList)
            
            Section("Mealtime filters") {
                Button{
                    withAnimation {
                        showMealtimeFilterList.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("Choose a Mealtime filter")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showMealtimeFilterList ? 180 : 0)) // Rotate arrow based on state
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .animation(.easeInOut(duration: 0.3), value: showMealtimeFilterList)
                    }
                }
                if showMealtimeFilterList {
                    
                    ForEach(mealtimeFilters) { filter in
                        let mealtime = filter.mealtime ?? "" // Provide fallback for optional mealtime
                        let plateCount = dataController.countMealtimePlates(for: mealtime)
                        
                        NavigationLink(value: filter) {
                            HStack {
                                Text(filter.name)
                                Spacer()
                                Text("\(plateCount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showTagFilterList)
            
            Section("Quality filters") {
                ForEach(qualityFilters) { filter in
                    NavigationLink(value: filter) {
                        HStack {
                            Image(systemName: filter.icon)
                                .foregroundColor(filter.quality == 0 ? .red : filter.quality == 1 ? .yellow : .green)
                            Text(filter.name)
                            Spacer()
                            Text("\(dataController.countQualityPlates(for: filter.quality))")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if dataController.countQualityPlates(for: 2) > dataController.countQualityPlates(for: 0) && dataController.countQualityPlates(for: 2) > dataController.countQualityPlates(for: 1) {
                    Text("You're doing great! Keep up with the healthy choices!")
                        .foregroundColor(.green)
                        .italic()
                } else if dataController.countQualityPlates(for: 0) > dataController.countQualityPlates(for: 2) && dataController.countQualityPlates(for: 0) > dataController.countQualityPlates(for: 1) {
                    Text("You may want to focus on eating healthier.")
                        .foregroundColor(.red)
                        .italic()
                } else {
                    Text("You're balancing your choices well!")
                        .foregroundColor(.orange)
                        .italic()
                }
            }
            
          
            
        }
        .toolbar {
//            Button(action: dataController.newTag) {
//                Label("Add tag", systemImage: "plus")
//            }
            
            Button {
                showingAwards.toggle()
            } label: {
                Label("Show awards", systemImage: "rosette")
            }
        }
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        .sheet(isPresented: $showCalendarSheet, content: CalendarSheetView.init)
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
    }



    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
    
    func delete(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.delete(tag)
        dataController.save()
    }
    
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
    
    // Ensure the filter changes are reflected properly when selecting "All" or "Today"
       private func resetFilters() {
           if dataController.selectedFilter == Filter.all {
               dataController.selectedDate = nil
           } else if dataController.selectedFilter == Filter.filterForDate(Date()) {
               dataController.selectedDate = Date()
           }
       }
   }

#Preview {
    SideBarView()
        .environmentObject(DataController.preview)
}
