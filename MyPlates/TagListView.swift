//
//  TagListView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 21.01.2025.
//

import SwiftUI

struct TagListView: View {
    @EnvironmentObject var dataController: DataController
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    @ObservedObject var plate: Plate
    @Environment(\.dismiss) var dismiss
    
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    @State private var searchQuery = "" // State for the search query
    @State private var selectedTags = Set<Tag>() // Set to store selected tags

    
    private var otherTags: [Tag] {
        dataController.missingTags(from: plate)
        }
    
    private var filteredTags: [Tag] {
            if searchQuery.isEmpty {
                return otherTags
            } else {
                return otherTags.filter { tag in
                    tag.tagName.lowercased().contains(searchQuery.lowercased())
                }
            }
        }
    
    var body: some View {
        NavigationStack{
            
            ZStack{
               
            VStack {
                if tags.count < 20 {
                    Button("Create default tags"){
                        let context = dataController.container.viewContext
                        dataController.createDefaultTags(context: context)
                    }
                }
   
                Text("Press and hold or swipe left on a tag to rename or delete it.")
                    .font(.caption)
                List{
                    Section("Current Tags"){
                        ForEach(plate.plateTags, id: \.self) { tag in
                            HStack {
                                Text(tag.tagName)
                                Spacer()
                                Button(action: {
                                    removeTagFromPlate(tag) // Remove tag from plate
                                }) {
                                    HStack{
                                        Text("Remove")
                                            .font(.caption)
                                        Image(systemName: "minus.circle")
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                            .contextMenu {
                                Button {
                                    rename(tag)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    delete(tag)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                // Add a rename swipe action
                                Button {
                                    rename(tag)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                                
                                // Add a delete swipe action
                                Button(role: .destructive) {
                                    delete(tag)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    
                    // List for other tags (tags not added yet)
                    
                    Section("Available Tags"){
                        ForEach(filteredTags, id: \.self) { tag in
                            HStack {
                                Text(tag.tagName)
                                    .foregroundColor(dataController.isTagRecentlyCreated(tag: tag) ? .green : .black)
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contextMenu {
                                Button {
                                    rename(tag)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    delete(tag)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                // Add a rename swipe action
                                Button {
                                    rename(tag)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                                
                                // Add a delete swipe action
                                Button(role: .destructive) {
                                    delete(tag)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contentShape(Rectangle()) // Makes the entire row tappable
                            .onTapGesture {
                                toggleSelection(for: tag) // Toggle selection when tapped
                            }
                        }
                    }
                }
                .searchable(text: $searchQuery) // Adds the search bar
                
            }
            .background(.gray.opacity(0.1))
                // Floating Action Button
                VStack {
                      
                    Spacer()
                    Button(action: {
                            addSelectedTagsToPlate()
                            dismiss()
                        }) {
                            Text("Add Selected Tags to Plate")
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(.white)
                                .stroke(.gray)
                            )
                        .disabled(selectedTags.isEmpty)
                }
        }
            
            .navigationTitle("Food tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: dataController.newTag) {
                    Label("Add tag", systemImage: "plus")
                }
            }
        }
        
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
//                .onAppear{
//                    let context = dataController.container.viewContext
//                    dataController.createDefaultTags(context: context)
//    }
   }
    
    func toggleSelection(for tag: Tag) {
            if selectedTags.contains(tag) {
                selectedTags.remove(tag) // If already selected, deselect it
            } else {
                selectedTags.insert(tag) // If not selected, select it
            }
        }
        
        // Function to add selected tags to the plate's tags relationship
        func addSelectedTagsToPlate() {
            for tag in selectedTags {
                plate.addToTags(tag)
            }
            
            // Save changes to the Core Data context
            dataController.save()
            
            // Clear the selection after adding tags
            selectedTags.removeAll()
        }
        
        // Function to remove a tag from the plate
        func removeTagFromPlate(_ tag: Tag) {
            plate.removeFromTags(tag) // Remove the tag from the plate's tags relationship
            dataController.save() // Save the changes to Core Data
        }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = otherTags[offset]
            dataController.delete(item)
        }
    }
    
    func delete(_ tag: Tag) {
        dataController.delete(tag)
        dataController.save()
    }
    
    func rename(_ tag: Tag) {
        tagToRename = tag
        tagName = tag.tagName
        renamingTag = true
    }
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
    
    
}

#Preview {
    TagListView(plate:.example)
}
