//
//  Motivation.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 12.02.2025.
//

import Foundation

//struct Motivation: Identifiable, Equatable {
//    let id: Int
//  //  let text: LocalizedStringResource   //for localization: String.LocalizationValue
//  //  let text: String
//    let text: String.LocalizationValue
//}

struct Motivation: Identifiable, Equatable {
    let id: Int
    let textKey: String // Store the key for the localization string, not the actual string

    var localizedText: String {
        return NSLocalizedString(textKey, tableName: "Motivations", comment: "")
    }

    init(id: Int, textKey: String) {
        self.id = id
        self.textKey = textKey
    }
}
