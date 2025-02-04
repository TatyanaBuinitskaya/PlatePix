//
//  Award.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 24.12.2024.
//

import Foundation

/// A model representing an award that a user can earn within the app.
/// Conforms to `Codable` for easy encoding/decoding and `Identifiable` for unique identification.
struct Award: Codable, Identifiable {
    /// The unique identifier for the award, derived from its name.
    var id: String { name }
    /// The name of the award.
    var name: String
    /// The description providing details about the award.
    var description: String
    /// The color associated with the award, represented as a string.
    var color: String
    /// The criterion that needs to be met to earn the award.
    var criterion: String
    /// The value associated with the criterion, representing the threshold for earning the award.
    var value: Int
    /// The name of the image associated with the award.
    var image: String
    /// A static property that loads all awards from the `Awards.json` file within the app bundle.
    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    /// A static property providing an example award, typically used for previews or testing.
    static let example = allAwards[0]
}
