//
//  TagListView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 21.01.2025.
//

import SwiftUI
import CoreData

/// A view that displays a list of tags and allows users to add, remove, or manage default tags.
struct TagListView: View {
    /// The data controller responsible for managing tag data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The current color scheme of the app (light or dark mode).
    @Environment(\.colorScheme) var colorScheme
    /// The plate to which tags are associated.
    @ObservedObject var plate: Plate
    /// The environment dismiss action to close the view.
    @Environment(\.dismiss) var dismiss
    /// The search query input by the user for filtering tags.
    @State private var searchQuery = ""
    /// The set of selected tags to be added to the plate.
    @State private var selectedTags = Set<Tag>()
    /// The set of tag groups that are currently expanded in the UI.
    @State private var expandedGroups: Set<String> = []
    /// A flag indicating whether default month tags should be shown.
    @AppStorage("showDedaultMonthTags") var showDedaultMonthTags: Bool = false
    /// A flag indicating whether default food tags should be shown.
    @AppStorage("showDedaultFoodTags") var showDedaultFoodTags: Bool = false
    /// A flag indicating whether default emotion tags should be shown.
    @AppStorage("showDedaultEmotionTags") var showDedaultEmotionTags: Bool = false
    /// A flag indicating whether default reaction tags should be shown.
    @AppStorage("showDedaultReactionTags") var showDedaultReactionTags: Bool = false
    /// The list of filtered tags based on the search query.
    private var filteredTags: [Tag] {
        searchQuery.isEmpty ?
        dataController.missingTags(from: plate) :
        dataController.missingTags(from: plate).filter {
            let localizedTagName = NSLocalizedString(
                $0.tagName,
                tableName: dataController.tableNameForTagType($0.tagType),
                comment: "")
            return localizedTagName.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    HStack {
                        Spacer()
                        VStack(alignment: .center, spacing: 0) {
                            defaultTagsToggles
                            Text("Press and hold or swipe left on a tag to rename or delete it")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top)
                                .multilineTextAlignment(.center)
                        }
                        .padding(0)
                        Spacer()
                    }
                    .padding(0)
                    
                    List {
                            Section("Current tags") {
                                if !plate.plateTags.isEmpty {
                                    ForEach(plate.plateTags, id: \.self) { tag in
                                        TagRow(selectedTags: nil, tag: tag, removeAction: { removeTagFromPlate(tag) })
                                    }
                                } else {
                                    Text("No tags added yet")
                                        .fontWeight(.light)
                                }
                            }
                            Section("Add tags") {
                                let groupedTags = Dictionary(grouping: filteredTags) { $0.type ?? "Other" }
//                                ForEach(groupedTags.keys.sorted(by: dataController.sortTags), id: \.self) { type in
//                                    if dataController.availableTagTypes.contains(type) {
//                                        Section {
//                                            dataController.tagHeaderView(for: type, colorScheme: colorScheme)
//                                            if dataController.shouldShowTags(for: type) {
//                                                ForEach(groupedTags[type, default: []], id: \.id) { tag in
//                                                    TagRow(selectedTags: selectedTags, tag: tag)
//                                                        .contentShape(Rectangle())
//                                                        .onTapGesture {
//                                                            toggleSelection(for: tag)
//                                                        }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
                                ForEach(groupedTags.keys.sorted(by: dataController.sortTags), id: \.self) { type in
                                    if dataController.availableTagTypes.contains(type) {
                                        Section {
                                           
                                            dataController.tagHeaderView(for: type, colorScheme: colorScheme)
                            
                                            if dataController.shouldShowTags(for: type) || expandedGroups.contains(type) {
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
                    }
                    .accentColor(colorManager.selectedColor.color)
                    .searchable(text: $searchQuery)
                    .onChange(of: searchQuery) {
                        if searchQuery.isEmpty {
                                // Collapse all groups when the search query is cleared
                                expandedGroups.removeAll()
                            } else {
                                // Find tags matching the search query and update the expanded groups
                                let matchingTypes = Set(filteredTags.compactMap { $0.type })
                                // Expand only groups that contain matching tags
                                expandedGroups.formUnion(matchingTypes)
                            }
                    }
                    
            
            VStack {
                Spacer()
                Button("Add Selected Tags to Plate") {
                    addSelectedTagsToPlate()
                    dismiss()
                }
                .foregroundStyle(!selectedTags.isEmpty ? .white : Color(uiColor: .systemBackground))
                .padding(10)
                .background(Capsule().fill(!selectedTags.isEmpty ? colorManager.selectedColor.color : (Color.secondary)))
                .disabled(selectedTags.isEmpty)
                .padding(.bottom, 20)
            }
        }
    
         //   .background(.gray.opacity(0.1))
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Reload fetch request when the view appears to ensure data consistency.
            try? dataController.container.viewContext.save()
        }
    }

    
    /// Toggles the selection status of a tag.
    func toggleSelection(for tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    /// Adds selected tags to the plate.
    func addSelectedTagsToPlate() {
        for tag in selectedTags {
            plate.addToTags(tag)
        }
        dataController.save()
        selectedTags.removeAll()
    }

    /// Removes a tag from the plate.
    func removeTagFromPlate(_ tag: Tag) {
        plate.removeFromTags(tag)
        dataController.save()
    }
    
    /// A view containing toggles for default tags.
    private var defaultTagsToggles: some View {
        HStack {
            tagToggle(
                text: NSLocalizedString("Emotion", comment: ""),
                label: colorScheme == .dark ? "face.smiling.inverse" : "face.smiling",
                isOn: $showDedaultEmotionTags,
                type: "emotion")
            tagToggle(
                text: NSLocalizedString("Food", comment: ""),
                label: "fork.knife.circle",
                isOn: $showDedaultFoodTags,
                type: "food")
            tagToggle(
                text: NSLocalizedString("Month", comment: ""),
                label: "30.square",
                isOn: $showDedaultMonthTags,
                type: "month")
            tagToggle(
                text: NSLocalizedString("Reaction", comment: ""),
                label: "heart.text.square",
                isOn: $showDedaultReactionTags,
                type: "reaction")
            Button {
                        dataController.newTag()
                } label: {
                    VStack(spacing: 3) {
                        Text("My")
                            .font(.caption)
                            .foregroundStyle(.primary)
                        Image(systemName: "plus")
                            .foregroundStyle(Color.white)
                            .font(.title2)
                            .padding(6)
                            .background {
                                Circle()
                                    .fill(colorManager.selectedColor.color)
                            }
                       
                    }
                    .frame(width: 60)
            }
                .buttonStyle(PlainButtonStyle())
            }
          //  .padding(5)
          //  .frame(maxWidth: .infinity)
          //  .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.1)))
          //  .padding()
    }

    /// A toggle button for managing default tags.
    private func tagToggle(text: String, label: String, isOn: Binding<Bool>, type: String) -> some View {
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                VStack(spacing: 3) {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(isOn.wrappedValue ? .primary : Color.gray)
                    Image(systemName: label)
                        .foregroundStyle(isOn.wrappedValue ? Color.white : Color.gray)
                        .font(.title2)
                        .padding(5)
                        .background {
                            Circle()
                                .fill(isOn.wrappedValue ? colorManager.selectedColor.color : .clear)
                        }
                        .symbolRenderingMode(.monochrome)
                }
                .frame(width: 60)
        }
            .buttonStyle(PlainButtonStyle())
        .onChange(of: isOn.wrappedValue) {
            handleTagChange(for: type, isOn: isOn.wrappedValue)
        }
    }

    /// Handles tag creation or deletion based on toggle state.
    private func handleTagChange(for type: String, isOn: Bool) {
        if isOn {
            createDefaultTags(for: type)
        } else {
            deleteDefaultTags(for: type)
        }
    }

    /// Creates default tags of a specific type.
    private func createDefaultTags(for type: String) {
        switch type {
        case "month":
            createDefaultMonthTags(context: dataController.container.viewContext)
        case "food":
            createDefaultFoodTags(context: dataController.container.viewContext)
        case "emotion":
            createDefaultEmotionTags(context: dataController.container.viewContext)
        case "reaction":
            createDefaultReactionTags(context: dataController.container.viewContext)
        default:
            break
        }
    }

    /// Deletes default tags of a specific type.
    private func deleteDefaultTags(for type: String) {
        switch type {
        case "month":
            deleteDefaultMonthTags(context: dataController.container.viewContext)
        case "food":
            deleteDefaultFoodTags(context: dataController.container.viewContext)
        case "emotion":
            deleteDefaultEmotionTags(context: dataController.container.viewContext)
        case "reaction":
            deleteDefaultReactionTags(context: dataController.container.viewContext)
        default:
            break
        }
    }
  
    /// Deletes default tags based on the provided tag type.
       ///
       /// - Parameters:
       ///   - tagType: The tag type (e.g., "Food", "Month") of tags to be deleted.
       ///   - context: The NSManagedObjectContext used to delete the tags.
    func deleteDefaultTags(tagType: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@", tagType)
        do {
            let tagsToDelete = try context.fetch(fetchRequest)
            for tag in tagsToDelete {
                context.delete(tag)
            }
            removeTagTypeIfNeeded(tagType)
            saveContext(context)
            print("Successfully deleted all \(tagType) tags")
        } catch {
            print("Failed to delete \(tagType) tags: \(error)")
        }
    }
        /// Creates default food tags by calling `createDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for creating tags.
        func createDefaultFoodTags(context: NSManagedObjectContext) {
            createDefaultTags(tagType: "Food", tagNames: defaultFoodTags, context: context)
        }

        /// Deletes default food tags by calling `deleteDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for deleting tags.
        func deleteDefaultFoodTags(context: NSManagedObjectContext) {
            deleteDefaultTags(tagType: "Food", context: context)
        }

        /// Creates default month tags by calling `createDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for creating tags.
        func createDefaultMonthTags(context: NSManagedObjectContext) {
//            let defaultMonthTags = [
//                "January", "February", "March", "April", "May", "June",
//                "July", "August", "September", "October", "November", "December"
//            ]
                //.map { NSLocalizedString($0, tableName: "DefaultMonths", comment: "") }
            createDefaultTags(tagType: "Month", tagNames: defaultMonthTags, context: context)
        }

        /// Deletes default month tags by calling `deleteDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for deleting tags.
        func deleteDefaultMonthTags(context: NSManagedObjectContext) {
            deleteDefaultTags(tagType: "Month", context: context)
        }

        /// Creates default emotion tags by calling `createDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for creating tags.
        func createDefaultEmotionTags(context: NSManagedObjectContext) {
            createDefaultTags(tagType: "Emotion", tagNames: defaultEmotionTags, context: context)
        }

        /// Deletes default emotion tags by calling `deleteDefaultTags` with the appropriate parameters.
           ///
           /// - Parameter context: The NSManagedObjectContext used for deleting tags.
        func deleteDefaultEmotionTags(context: NSManagedObjectContext) {
            deleteDefaultTags(tagType: "Emotion", context: context)
        }

        /// Creates default reaction tags by calling `createDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for creating tags.
        func createDefaultReactionTags(context: NSManagedObjectContext) {
            createDefaultTags(tagType: "Reaction", tagNames: defaultReactionTags, context: context)
        }

        /// Deletes default reaction tags by calling `deleteDefaultTags` with the appropriate parameters.
            ///
            /// - Parameter context: The NSManagedObjectContext used for deleting tags.
        func deleteDefaultReactionTags(context: NSManagedObjectContext) {
            deleteDefaultTags(tagType: "Reaction", context: context)
        }
    
    /// Adds a tag type to the list of available tag types if it isn't already present.
       ///
       /// - Parameter tagType: The tag type to be added.
    private func addTagTypeIfNeeded(_ tagType: String) {
        if !dataController.availableTagTypes.contains(tagType) {
            dataController.availableTagTypes.append(tagType)
        }
    }

    /// Removes a tag type from the list of available tag types if it exists.
        ///
        /// - Parameter tagType: The tag type to be removed.
    private func removeTagTypeIfNeeded(_ tagType: String) {
        if let index = dataController.availableTagTypes.firstIndex(of: tagType) {
            dataController.availableTagTypes.remove(at: index)
        }
    }

    /// Saves the provided context to Core Data, handling any errors that may occur.
        ///
        /// - Parameter context: The NSManagedObjectContext to save.
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }


    /// Creates default tags if they don't already exist. Each tag is associated with a tag type.
        ///
        /// - Parameters:
        ///   - tagType: The type of the tag to be created (e.g., "Food", "Month").
        ///   - tagNames: A list of tag names to be created.
        ///   - context: The NSManagedObjectContext used for saving the tag to the Core Data store.
    func createDefaultTags(tagType: String, tagNames: [String], context: NSManagedObjectContext) {
        for tagName in tagNames {
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)
            // If the tag doesn't exist, create and save it
            if (try? context.count(for: fetchRequest)) == 0 {
                let tag = Tag(context: context)
                tag.id = UUID()
                tag.name = tagName
                tag.type = tagType
                addTagTypeIfNeeded(tagType)
            }
        }
        saveContext(context)
    }
    
//    func createDefaultTags(tagType: String, tagNames: [String], context: NSManagedObjectContext, tableName: String) {
//        for tagName in tagNames {
//            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)
//
//            // Fetch the existing tag if it exists
//            let existingTags = (try? context.fetch(fetchRequest)) ?? []
//
//            // If the tag exists, update its name with localized string
//            if let tag = existingTags.first {
//                // Update the name with the localized version from the specified table
//                let localizedTagName = NSLocalizedString(tagName, tableName: tableName, comment: "")
//                tag.name = localizedTagName
//            } else {
//                // If the tag doesn't exist, create a new one
//                let tag = Tag(context: context)
//                tag.id = UUID() // Assign a new UUID for the tag
//                tag.name = NSLocalizedString(tagName, tableName: tableName, comment: "") // Store the localized name
//                tag.type = tagType
//                addTagTypeIfNeeded(tagType)
//            }
//        }
//        saveContext(context)
//    }
}

/// A SwiftUI view that displays an individual tag with options to edit or delete.
/// This view handles tag display, selection state, and provides context menus for tag management.
struct TagRow: View {
    /// The data controller managing the tag data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The tag currently being edited, if any.
    @State private var tagToEdit: Tag?
    /// A Boolean value indicating whether the tag is in editing mode.
    @State private var editingTag = false
    /// The name of the tag to be edited.
    @State private var tagName = ""
    /// The type of the tag to be edited.
    @State private var tagType = ""
    /// The set of selected tags, used to display a checkmark for selected tags.
    var selectedTags: Set<Tag>?
    /// The tag represented by this view.
    var tag: Tag
    /// An optional closure that defines an action to remove the tag.
    var removeAction: (() -> Void)?

    var body: some View {
        HStack {
            // Displays the tag name with a color indicating if it was recently created.
            Text(NSLocalizedString(tag.tagName, tableName: dataController.tableNameForTagType(tag.type), comment: ""))
                .fontWeight(.light)
                .foregroundStyle(isTagRecentlyCreated(tag: tag) ? colorManager.selectedColor.color : .primary)
            Spacer()
            // Conditionally displays a "Remove" button if `removeAction` is provided.
            if let removeAction = removeAction {
                Button {
                    removeAction()
                } label: {
                    HStack {
                       // Text("Remove").font(.caption)
                        Image(systemName: "tag.slash")
                    }
                    .foregroundStyle(colorManager.selectedColor.color)
                }
            } else if selectedTags?.contains(tag) == true {
                // Shows a checkmark if the tag is part of the selected tags.
                Image(systemName: "checkmark")
            }
        }
        .contextMenu {
            // Provides options to rename or delete the tag when long-pressed.
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
            // Allows quick swipe actions to rename or delete the tag.
            Button {
                edit(tag)
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(colorManager.selectedColor.color)

            Button(role: .destructive) {
                delete(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .alert("Rename Tag", isPresented: $editingTag) {
            // Displays an alert for renaming the tag with input fields for name and type.
            TextField("New Name", text: $tagName)
            TextField("New Type", text: $tagType)
            Button("OK", action: {
                completeEdit()
            })
            Button("Cancel", role: .cancel) { }
        }
    }

    /// Initiates the editing process for the specified tag.
        /// - Parameter tag: The tag to be edited.
    func edit(_ tag: Tag) {
        tagToEdit = tag
        tagName = tag.tagName
        tagType = tag.tagType
        editingTag = true
    }

    /// Completes the editing process by saving the updated tag name and type.
       /// Ensures the new tag type is added to the available types if not already present.
    func completeEdit() {
           tagToEdit?.name = tagName
           tagToEdit?.type = tagType
        if !dataController.availableTagTypes.contains(tagType) {
            dataController.availableTagTypes.append(tagType)
            }
           dataController.save()
       }

    /// Deletes the specified tag from the data source and saves the changes.
        /// - Parameter tag: The tag to be deleted.
    func delete(_ tag: Tag) {
        dataController.delete(tag)
        dataController.save()  
    }
    /// Checks if a tag was created within the last hour.
        /// - Parameter tag: The tag to check.
        /// - Returns: True if the tag was created within the last hour, otherwise false.
    func isTagRecentlyCreated(tag: Tag) -> Bool {
        guard let creationDate = tag.creationDate else { return false }
        let timeInterval = Date().timeIntervalSince(creationDate)
        return timeInterval <= 3600 // 3600 seconds = 1 hour
    }
}

#Preview("English") {
    TagListView(plate: .example)
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    TagListView(plate: .example)
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
