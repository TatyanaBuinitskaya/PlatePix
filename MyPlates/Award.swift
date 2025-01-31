//
//  Award.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 24.12.2024.
//

import Foundation

struct Award: Codable, Identifiable {
    var id: String { name }
    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String
    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    static let example = allAwards[0]
}
