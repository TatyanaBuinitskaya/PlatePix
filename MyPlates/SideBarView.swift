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
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    
    @State private var showingAwards = false
    @State private var showCalendarSheet = false
    
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "fork.knife.circle", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Date Filters") {
//                ForEach(smartFilters) { filter in
//                    NavigationLink(value: filter) {
//                        HStack {
//                            Label(filter.name, systemImage: filter.icon)
//                            Spacer()
//                            if filter == Filter.all {
//                                Text("\(dataController.allPlatesCount)")
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
                Button {
                    dataController.selectedFilter = Filter.all
                    dataController.selectedDate = nil
                } label: {
                    Label("All plates", systemImage: "calendar")
                }
                
                Button {
                    dataController.selectedFilter = Filter.filterForDate(Date())
                    dataController.selectedDate = Date()
                } label: {
                    Label("Today", systemImage: "1.square")
                }
                
                Button {
                    showCalendarSheet = true
                } label: {
                    Label("Select date", systemImage: "calendar.circle")
                }
            }
            
            Section("Tags") {
                if tagFilters.isEmpty {
                    Button {
                        let context = dataController.container.viewContext
                        dataController.createDefaultTags(context: context)
                    } label: {
                        Label("Create default tags", systemImage: "plus.square.on.square")
                    }
                }
                
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                          //  .badge(filter.tag?.tagTodayPlates.count ?? 0)
                            .contextMenu {
                                Button {
                                    rename(filter)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    delete(filter)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .onDelete(perform: delete)
            }
            
            Section("Quality Filters") {
                ForEach(qualityFilters) { filter in
                    NavigationLink(value: filter) {
                        HStack {
                            Image(systemName: filter.icon)
                                .foregroundColor(filter.quality == 0 ? .red : filter.quality == 1 ? .yellow : .green)
                            Text(filter.name)
                            Spacer()
                            Text("\(dataController.countPlates(for: filter.quality))")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if dataController.countPlates(for: 2) > dataController.countPlates(for: 0) && dataController.countPlates(for: 2) > dataController.countPlates(for: 1) {
                    Text("You're doing great! Keep up with the healthy choices!")
                        .foregroundColor(.green)
                        .italic()
                } else if dataController.countPlates(for: 0) > dataController.countPlates(for: 2) && dataController.countPlates(for: 0) > dataController.countPlates(for: 1) {
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
            Button(action: dataController.newTag) {
                Label("Add tag", systemImage: "plus")
            }
            
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
