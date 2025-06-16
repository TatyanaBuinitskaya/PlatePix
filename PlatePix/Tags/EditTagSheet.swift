//
//  EditTagSheet.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 11.04.2025.
//

import SwiftUI

/// A view that allows editing an existing `Tag` object.
struct EditTagSheet: View {
    /// The data controller responsible for managing tag data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The environment dismiss action to close the view.
    @Environment(\.dismiss) var dismiss
    /// The tag being edited, passed as an observed object.
    @ObservedObject var tag: Tag
    /// The editable name of the tag.
    //  @State private var tagName: String
    @State private var tagName: String
    /// The editable type of the tag.
    @State private var tagType: String
    /// Initializes the sheet with the given tag, preloading its current name and type.
    init(tag: Tag) {
        self.tag = tag
        _tagName = State(initialValue: "")
        _tagType = State(initialValue: "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Tag")) {
                    TextField("New Name", text: $tagName)
                    TextField("New Type", text: $tagType)
                }
                Section {
                    HStack {
                        Spacer()
                        Button("Save") {
                            saveEdit()
                            dismiss()
                        }
                        .disabled(tagName.isEmpty || tagType.isEmpty)
                        .padding(5)
                        .padding(.horizontal, 20)
                        .background(Capsule().fill(colorManager.selectedColor.color))
                        .foregroundStyle(.white)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Localize tagName and tagType when the view appears
            _tagName.wrappedValue = NSLocalizedString(tag.tagName, tableName: dataController.tableNameForTagType(tag.tagType), comment: "")
            _tagType.wrappedValue = NSLocalizedString(tag.tagType, comment: "")
        }
    }

    /// Saves the edited tag back into the data controller.
    func saveEdit() {
        let mappedType = dataController.mapLocalizedTypeToDefaultType(localizedType: tagType)
        tag.name = tagName
        tag.type = mappedType
        if !dataController.availableTagTypes.contains(mappedType) {
            dataController.availableTagTypes.append(mappedType)
        }
        dataController.save()
    }
}

#Preview {
    EditTagSheet(tag: .example)
}

