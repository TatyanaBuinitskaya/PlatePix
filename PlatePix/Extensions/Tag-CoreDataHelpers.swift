//
//  Tag-CoreDataHelpers.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation

/// An extension to the `Tag` model that provides computed properties for easier access and management of tag-related data.
extension Tag {
    /// The unique identifier for the tag. Generates a new UUID if not set to ensure uniqueness.
    var tagID: UUID {
        id ?? UUID()
    }
    /// The name of the tag. Returns an empty string if the name is not provided.
    var tagName: String {
        name ?? ""
    }
    /// The type of the tag, indicating whether it is user-defined or system-generated. Defaults to "User" if not specified.
    var tagType: String {
        type ?? "My"
    }
    /// The creation date of the tag. Defaults to the current date if not set to avoid `nil` values.
    var tagCreationDate: Date {
        creationDate ?? .now
    }
    /// A sample `Tag` object used for previewing or testing purposes.
    ///
    /// This example tag is configured with sample data, including an ID, name, and creation date,
    /// making it useful for SwiftUI previews or unit tests.
    static var example: Tag {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example tag"
        tag.creationDate = .now
        return tag
    }
    var localizedTagName: String {
           return NSLocalizedString(self.tagName, comment: "")
       }
}

/// Extends the `Tag` model to conform to the `Comparable` protocol, allowing tags to be compared based on their names and IDs.
extension Tag: Comparable {
    /// Compares two `Tag` instances based on their names in a case-insensitive manner.
    ///
    /// - If the names are identical, the comparison falls back to comparing the UUIDs to ensure deterministic sorting.
    /// - This is useful for displaying tags in alphabetical order with consistent ordering for duplicate names.
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase
        if left == right {
            return lhs.tagID < rhs.tagID
        } else {
            return left < right
        }
    }
}
