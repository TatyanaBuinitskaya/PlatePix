//
//  TagListView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 21.01.2025.
//

import SwiftUI

struct TagListView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    @Environment(\.dismiss) var dismiss
    @State private var searchQuery = ""
    @State private var selectedTags = Set<Tag>()
    @State private var expandedGroups: Set<String> = []
    @AppStorage("showDedaultMonthTags") var showDedaultMonthTags: Bool = false
    @AppStorage("showDedaultFoodTags") var showDedaultFoodTags: Bool = false
    @AppStorage("showDedaultEmotionTags") var showDedaultEmotionTags: Bool = false
    @AppStorage("showDedaultReactionTags") var showDedaultReactionTags: Bool = false
    private var filteredTags: [Tag] {
        searchQuery.isEmpty ?
        dataController.missingTags(from: plate) :
        dataController.missingTags(from: plate).filter { $0.tagName.lowercased().contains(searchQuery.lowercased()) }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                  Text("Create or delete default tags")
                    defaultTagsToggles
                    Text("Press and hold or swipe left on a tag to rename or delete it")
                        .font(.caption)
                        .padding()
                    List {
                        Section("Current Tags") {
                            ForEach(plate.plateTags, id: \.self) { tag in
                                TagRow(selectedTags: nil, tag: tag, removeAction: { removeTagFromPlate(tag) })
                            }
                        }
                        Section {
                            let groupedTags = Dictionary(grouping: filteredTags) { $0.type ?? "Other" }
                            ForEach(groupedTags.keys.sorted(by: dataController.sortTags), id: \.self) { type in
                                if dataController.availableTagTypes.contains(type) {
                                    Section {
                                        dataController.tagHeaderView(for: type)
                                        if dataController.shouldShowTags(for: type) {
                                            ForEach(groupedTags[type, default: []], id: \.id) { tag in
                                                TagRow(selectedTags: selectedTags, tag: tag)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        toggleSelection(for: tag)
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchQuery)
                }
                VStack {
                    Spacer()
                    Button("Add Selected Tags to Plate") {
                        addSelectedTagsToPlate()
                        dismiss()
                    }
                    .padding()
                    .background(Capsule().fill(Color.white).stroke(Color.gray))
                    .disabled(selectedTags.isEmpty)
                    .padding(.bottom, 20)
                }
            }
            .background(.gray.opacity(0.1))
            .navigationTitle("Food Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: dataController.newTag) {
                   // Label("Add Tag", systemImage: "plus")
                    HStack {
                        Text("Add tag")
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            // Force reload of the fetch request when the view appears
            try? dataController.container.viewContext.save()
        }
    }
    func toggleSelection(for tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    func addSelectedTagsToPlate() {
        for tag in selectedTags {
            plate.addToTags(tag)
        }
        dataController.save()
        selectedTags.removeAll()
    }
    func removeTagFromPlate(_ tag: Tag) {
        plate.removeFromTags(tag)
        dataController.save()
    }
    private var defaultTagsToggles: some View {
        HStack {
            tagToggle(label: "Emotion", isOn: $showDedaultEmotionTags, type: "emotion")
            tagToggle(label: "Food", isOn: $showDedaultFoodTags, type: "food")
            tagToggle(label: "Month", isOn: $showDedaultMonthTags, type: "month")
            tagToggle(label: "Reaction", isOn: $showDedaultReactionTags, type: "reaction")
        }
        .padding(5)
        .background(Capsule().fill(Color.blue))
    }
//    private func tagToggle(label: String, isOn: Binding<Bool>, type: String) -> some View {
//        HStack {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)
//            Button {
//                isOn.wrappedValue.toggle() // Toggle the button's state
//            } label: {
//                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
//                    .foregroundColor(.white)
//                    .font(.title2)
//            }
//        }
//        .onChange(of: isOn.wrappedValue) {
//            if isOn.wrappedValue {
//                switch type {
//                case "month":
//                    dataController.createDefaultMonthTags(
//                        context: dataController.container.viewContext)
//                case "food":
//                    dataController.createDefaultFoodTags(context: dataController.container.viewContext)
//                case "emotion":
//                    dataController.createDefaultEmotionTags(context: dataController.container.viewContext)
//                case "reaction":
//                    dataController.createDefaultReactionTags(context: dataController.container.viewContext)
//                default:
//                    break
//                }
//            } else {
//                switch type {
//                case "month":
//                    dataController.deleteDefaultMonthTags(context: dataController.container.viewContext)
//                case "food":
//                    dataController.deleteDefaultFoodTags(context: dataController.container.viewContext)
//                case "emotion":
//                    dataController.deleteDefaultEmotionTags(context: dataController.container.viewContext)
//                case "reaction":
//                    dataController.deleteDefaultReactionTags(context: dataController.container.viewContext)
//                default:
//                    break
//                }
//            }
//        }
//    }
    private func tagToggle(label: String, isOn: Binding<Bool>, type: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Button {
                isOn.wrappedValue.toggle() // Toggle the button's state
            } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
        .onChange(of: isOn.wrappedValue) {
            handleTagChange(for: type, isOn: isOn.wrappedValue)
        }
    }
    // New method to handle tag creation and deletion
    private func handleTagChange(for type: String, isOn: Bool) {
        if isOn {
            createDefaultTags(for: type)
        } else {
            deleteDefaultTags(for: type)
        }
    }
    // New method to handle tag creation
    private func createDefaultTags(for type: String) {
        switch type {
        case "month":
            dataController.createDefaultMonthTags(context: dataController.container.viewContext)
        case "food":
            dataController.createDefaultFoodTags(context: dataController.container.viewContext)
        case "emotion":
            dataController.createDefaultEmotionTags(context: dataController.container.viewContext)
        case "reaction":
            dataController.createDefaultReactionTags(context: dataController.container.viewContext)
        default:
            break
        }
    }
    // New method to handle tag deletion
    private func deleteDefaultTags(for type: String) {
        switch type {
        case "month":
            dataController.deleteDefaultMonthTags(context: dataController.container.viewContext)
        case "food":
            dataController.deleteDefaultFoodTags(context: dataController.container.viewContext)
        case "emotion":
            dataController.deleteDefaultEmotionTags(context: dataController.container.viewContext)
        case "reaction":
            dataController.deleteDefaultReactionTags(context: dataController.container.viewContext)
        default:
            break
        }
    }
}

struct TagRow: View {
    @EnvironmentObject var dataController: DataController
    @State private var tagToEdit: Tag?
    @State private var editingTag = false
    @State private var tagName = ""
    @State private var tagType = ""
    var selectedTags: Set<Tag>?
    var tag: Tag
    var removeAction: (() -> Void)?
    var body: some View {
        HStack {
            Text(tag.tagName)
                .fontWeight(.light)
                .foregroundColor(dataController.isTagRecentlyCreated(tag: tag) ? .green : .black)
            Spacer()
            if let removeAction = removeAction {
                Button(action: removeAction) {
                    HStack {
                        Text("Remove").font(.caption)
                        Image(systemName: "minus.circle")
                    }
                    .foregroundColor(.red)
                }
            } else if selectedTags?.contains(tag) == true {
                Image(systemName: "checkmark")
            }
        }
        .contextMenu {
            Button {
                edit(tag)
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
            Button {
                edit(tag)
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.blue)

            Button(role: .destructive) {
                delete(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Rename Tag", isPresented: $editingTag) {
            TextField("New Name", text: $tagName)
            TextField("New Type", text: $tagType)
            Button("OK", action: completeEdit)
            Button("Cancel", role: .cancel) { }
        }
    }
    func edit(_ tag: Tag) {
        tagToEdit = tag
        tagName = tag.tagName
        tagType = tag.tagType
        editingTag = true
    }
    func completeEdit() {
           tagToEdit?.name = tagName
           tagToEdit?.type = tagType
        if !dataController.availableTagTypes.contains(tagType) {
            dataController.availableTagTypes.append(tagType)
            }
           dataController.save()
       }
    func delete(_ tag: Tag) {
        dataController.delete(tag)  // Make sure this deletes the tag from the data source
        dataController.save()  // Save the changes
    }
}

#Preview {
    TagListView(plate: .example)
}
