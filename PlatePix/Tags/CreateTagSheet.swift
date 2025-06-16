//
//  CreateTagSheet.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 16.04.2025.
//

import SwiftUI

/// A view for creating a new tag.
struct CreateTagSheet: View {
    /// The data controller responsible for managing tag data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The environment dismiss action to close the view.
    @Environment(\.dismiss) var dismiss
    /// The name of the new tag. Defaults to a localized "New Tag".
    @State private var tagName = NSLocalizedString("New Tag", comment: "")
    /// The type/category of the new tag. Defaults to a localized "My".
    @State private var tagType = NSLocalizedString("My", comment: "")

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Tag")) {
                    TextField("Name", text: $tagName)
                    TextField("Type", text: $tagType)
                }

                Section {
                    HStack {
                        Spacer()
                        Button("Save") {
                            createTag()
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
    }

    /// Creates and saves a new tag using the provided name and mapped type.
    func createTag() {
        let tag = dataController.newTag()
        tag.name = tagName
        tag.type = dataController.mapLocalizedTypeToDefaultType(localizedType: tagType)
        if !dataController.availableTagTypes.contains(tag.tagType) {
            dataController.availableTagTypes.append(tag.tagType)
        }
        dataController.save()
    }
}

#Preview {
    CreateTagSheet()
}
