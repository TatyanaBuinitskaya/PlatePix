//
//  TagListView.swift
//  PlatePix
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
    /// Controls the visibility of the alert shown when the user attempts to delete default tags.
    @State private var showAlert = false
    /// Stores the type of default tags that the user is attempting to delete, used in the alert message.
    @State private var tagsToDelete: String = ""
    /// Localized name of the tag type selected for deletion.
    private var localizedTagToDelete: String {
        NSLocalizedString(tagsToDelete.capitalized, comment: "")
    }
    /// A shared settings manager that syncs tag visibility preferences across devices using iCloud.
    @StateObject var tagSettings = TagSettings()
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
                ScrollViewReader { proxy in
                    List {
                        VStack(alignment: .center) {
                            HStack {
                                Spacer()
                                VStack(alignment: .center, spacing: 10) {
                                    defaultTagsToggles
                                }
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
                            )
                            Text("Swipe left on a tag to rename or delete it")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                        .listRowBackground(Color.clear)

                        Section("Added tags") {

                            let typePriority: [String] = ["My", "Food", "Emotion", "Reaction"]

                            let sortedTags = plate.plateTags.sorted { firstTag, secondTag in
                                let firstTypePriority = typePriority.firstIndex(of: firstTag.tagType) ?? Int.max
                                let secondTypePriority = typePriority.firstIndex(of: secondTag.tagType) ?? Int.max

                                if firstTypePriority == secondTypePriority {
                                    let firstLocalized = NSLocalizedString(
                                        firstTag.tagName,
                                        tableName: dataController.tableNameForTagType(firstTag.type),
                                        comment: ""
                                    )
                                    let secondLocalized = NSLocalizedString(
                                        secondTag.tagName,
                                        tableName: dataController.tableNameForTagType(secondTag.type),
                                        comment: ""
                                    )

                                    return firstLocalized.localizedStandardCompare(secondLocalized) == .orderedAscending
                                }
                                return firstTypePriority < secondTypePriority
                            }

                            if !sortedTags.isEmpty {
                                ForEach(sortedTags, id: \.self) { tag in
                                    TagRow(selectedTags: nil, tag: tag, removeAction: { removeTagFromPlate(tag) })
                                }
                            } else {
                                Text("No tags added yet")
                                    .fontWeight(.light)
                            }
                        }
                        Section("Add tags") {
                            let groupedTags = Dictionary(grouping: filteredTags) { $0.type ?? "Other" }

                            ForEach(groupedTags.keys.sorted(by: dataController.sortTags), id: \.self) { type in
                                if dataController.availableTagTypes.contains(type) {
                                    Section {
                                        dataController.tagHeaderView(for: type, colorScheme: colorScheme)

                                        if dataController.shouldShowTags(for: type) || expandedGroups.contains(type) {
                                            ForEach(groupedTags[type, default: []].sorted(by: { firstTag, secondTag in
                                                NSLocalizedString(
                                                    firstTag.tagName,
                                                    tableName: dataController.tableNameForTagType(firstTag.type),
                                                    comment: ""
                                                )
                                                    .localizedCompare(
                                                        NSLocalizedString(
                                                            secondTag.tagName,
                                                            tableName: dataController.tableNameForTagType(secondTag.type),
                                                            comment: ""
                                                        )
                                                    ) == .orderedAscending
                                            }), id: \.id) { tag in
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
                        Spacer(minLength: 5)
                            .listRowBackground(Color.clear)
                            .id("bottom")
                    }
                    .accentColor(colorManager.selectedColor.color)
                    .searchable(text: $searchQuery)
                    .onChange(of: searchQuery) {
                        if searchQuery.isEmpty {
                            expandedGroups.removeAll()
                        } else {
                            let matchingTypes = Set(filteredTags.compactMap { $0.type })
                            expandedGroups.formUnion(matchingTypes)

                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }
                VStack {
                    Spacer()
                    Button("Add Tags") {
                        addSelectedTagsToPlate()
                        dismiss()
                    }
                    .foregroundStyle(!selectedTags.isEmpty ? .white : Color(uiColor: .systemBackground))
                    .padding(10)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule().fill(!selectedTags.isEmpty ? colorManager.selectedColor.color : (Color.secondary))
                    )
                    .disabled(selectedTags.isEmpty)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Reload fetch request when the view appears to ensure data consistency.
            try? dataController.container.viewContext.save()
        }
        .sheet(isPresented: $dataController.showCreateTagSheet) {
            CreateTagSheet()
                .environmentObject(dataController)
                .environmentObject(colorManager)
                .presentationDetents([.medium])
        }
        .sheet(item: $dataController.tagToEdit) { tag in
            EditTagSheet(tag: tag)
                .environmentObject(dataController)
                .environmentObject(colorManager)
                .presentationDetents([.medium])
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
        print(selectedTags)
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
                text: NSLocalizedString("Food", comment: ""),
                label: "fork.knife.circle",
                isOn: $tagSettings.showDefaultFoodTags,
                type: "food")
            tagToggle(
                text: NSLocalizedString("Emotion", comment: ""),
                label: colorScheme == .dark ? "face.smiling.inverse" : "face.smiling",
                isOn: $tagSettings.showDefaultEmotionTags,
                type: "emotion")
            tagToggle(
                text: NSLocalizedString("Reaction", comment: ""),
                label: "heart.text.square",
                isOn: $tagSettings.showDefaultReactionTags,
                type: "reaction")
            Button {
                dataController.showCreateTagSheet = true
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
        .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Deleting the default \(localizedTagToDelete) tags will also remove them from any plates where they were previously used."),
                    primaryButton: .cancel {},
                    secondaryButton: .destructive(Text("Delete")) {
                        deleteDefaultTags(for: tagsToDelete)
                        if tagsToDelete == "food" {
                            tagSettings.showDefaultFoodTags = false
                        } else if tagsToDelete == "emotion" {
                            tagSettings.showDefaultEmotionTags = false
                        } else if tagsToDelete == "reaction" {
                            tagSettings.showDefaultReactionTags = false
                        }
                    }
                )
            }
    }

    /// A toggle button for managing default tags.
    private func tagToggle(text: String, label: String, isOn: Binding<Bool>, type: String) -> some View {
        Button {
            handleTagChange(for: type, isOn: isOn)
        } label: {
            VStack(spacing: 3) {
                Text(text)
                    .font(.caption)
                    .foregroundStyle(isOn.wrappedValue ? .primary : Color.gray)
                 //   .foregroundStyle(initialToggleState ? .primary : Color.gray)
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
//        .alert(isPresented: $showAlert) {
//                Alert(
//                   title: Text("Warning"),
//                   message: Text("If you delete the default \(localizedTagToDelete) tags, all tags already saved in the plates will also be deleted."),
//                   primaryButton: .cancel {
//                   },
//                   secondaryButton: .destructive(Text("Delete")) {
//                       deleteDefaultTags(for: tagsToDelete)
//                       isOn.wrappedValue = false
//                   }
//               )
//           }
    }

    /// Handles tag creation or deletion based on toggle state.
    private func handleTagChange(for type: String, isOn: Binding<Bool>) {
        if isOn.wrappedValue == false {
            // Toggle ON
            isOn.wrappedValue = true
            deleteDefaultTags(for: type)
            createDefaultTags(for: type)
        } else {
            // Toggle OFF – show alert first
            tagsToDelete = type
            showAlert = true
        }
    }

    /// Creates default tags of a specific type.
    private func createDefaultTags(for type: String) {
        switch type {
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
    ///   - tagType: The tag type (e.g., "Food", "Emotion") of tags to be deleted.
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
    ///   - tagType: The type of the tag to be created (e.g., "Food", "Emotion").
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
}

/// A SwiftUI view that displays an individual tag with options to edit or delete.
/// This view handles tag display, selection state, and provides context menus for tag management.
struct TagRow: View {
    /// The data controller managing the tag data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
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
                        Image(systemName: "tag.slash")
                    }
                    .foregroundStyle(colorManager.selectedColor.color)
                }
            } else if selectedTags?.contains(tag) == true {
                // Shows a checkmark if the tag is part of the selected tags.
                Image(systemName: "checkmark")
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
    }

    /// Initiates the editing process for the specified tag.
    /// - Parameter tag: The tag to be edited.
    func edit(_ tag: Tag) {
        dataController.tagToEdit = tag
        dataController.tagName = tag.tagName
        dataController.tagType = tag.tagType
        dataController.showEditTagSheet = true
    }

    // MARK: Correct code for Localization to Different Languages!
    /// Maps a localized tag type (e.g., Russian) to the default type.
    /// - Parameter localizedType: The localized tag type (e.g., "Еда", "Эмоция") entered by the user.
    /// - Returns: The default tag type (e.g., "Food", "Emotion"). Returns the original input if not recognized.
    /// - Example:
    ///   mapLocalizedTypeToDefaultType(localizedType: "Еда") // returns "Food"
    func mapLocalizedTypeToDefaultType(localizedType: String) -> String {
        switch localizedType.lowercased() {
        case "еда", "food": // Handle different languages for 'Food'
            return "Food"
        case "эмоция", "emotion": // Handle different languages for 'Emotion'
            return "Emotion"
        case "реакция", "reaction": // Handle different languages for 'Reaction'
            return "Reaction"
        default:
            return localizedType // Return original if it's not recognized
        }
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
