//
//  Reminder.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 20.03.2025.
//

import Foundation

struct Reminder: Identifiable, Equatable {
    let id: Int
    let textKey: String // Store the key for the localization string, not the actual string

    var localizedText: String {
        return NSLocalizedString(textKey, tableName: "Reminders", comment: "")
    }

    init(id: Int, textKey: String) {
        self.id = id
        self.textKey = textKey
    }
}
