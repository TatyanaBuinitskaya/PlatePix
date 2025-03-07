//
//  UserPreferences.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 07.02.2025.
//

import Foundation

class UserPreferences: ObservableObject {
    static let shared = UserPreferences() // Singleton instance

    @Published var showMealTime: Bool {
        didSet { UserDefaults.standard.set(showMealTime, forKey: "showMealTime") }
    }

    @Published var showQuality: Bool {
        didSet { UserDefaults.standard.set(showQuality, forKey: "showQuality") }
    }

    @Published var showTags: Bool {
        didSet { UserDefaults.standard.set(showTags, forKey: "showTags") }
    }

    init() {
        self.showMealTime = UserDefaults.standard.bool(forKey: "showMealTime")
        self.showQuality = UserDefaults.standard.bool(forKey: "showQuality")
        self.showTags = UserDefaults.standard.bool(forKey: "showTags")
    }
}
