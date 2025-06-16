//
//  TagSettings.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 09.04.2025.
//

import Foundation
import Combine
import CoreData

/// A settings manager that handles the visibility of default tag categories (Food, Emotion, Reaction),
/// with support for both iCloud and UserDefaults synchronization.
class TagSettings: ObservableObject {
    /// Controls whether default food tags should be shown. Saves to iCloud and UserDefaults.
    @Published var showDefaultFoodTags: Bool {
        didSet {
            save("showDefaultFoodTags", value: showDefaultFoodTags)
        }
    }

    /// Controls whether default emotion tags should be shown. Saves to iCloud and UserDefaults.
    @Published var showDefaultEmotionTags: Bool {
        didSet {
            save("showDefaultEmotionTags", value: showDefaultEmotionTags)
        }
    }

    /// Controls whether default reaction tags should be shown. Saves to iCloud and UserDefaults.
    @Published var showDefaultReactionTags: Bool {
        didSet {
            save("showDefaultReactionTags", value: showDefaultReactionTags)
        }
    }

    /// The iCloud key-value store used to sync settings across devices.
    private let iCloud = NSUbiquitousKeyValueStore.default

    /// Standard UserDefaults for local persistence.
    private let defaults = UserDefaults.standard

    /// Initializes the TagSettings by loading saved values from UserDefaults or iCloud,
    /// and registering for iCloud sync notifications.
    init() {
        // Try to load preferences from iCloud first. If not available, fall back to UserDefaults.
        self.showDefaultFoodTags = iCloud.object(forKey: "showDefaultFoodTags") as? Bool
                                    ?? defaults.bool(forKey: "showDefaultFoodTags")
        self.showDefaultEmotionTags = iCloud.object(forKey: "showDefaultEmotionTags") as? Bool
                                       ?? defaults.bool(forKey: "showDefaultEmotionTags")
        self.showDefaultReactionTags = iCloud.object(forKey: "showDefaultReactionTags") as? Bool
                                        ?? defaults.bool(forKey: "showDefaultReactionTags")

        // Observe changes made to iCloud key-value store from other devices
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(syncFromiCloud),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloud
        )

        // Ensure latest data from iCloud is pulled on startup
        iCloud.synchronize()
    }

    /// Saves a setting value to both iCloud and UserDefaults.
    private func save(_ key: String, value: Bool) {
        defaults.set(value, forKey: key)
        iCloud.set(value, forKey: key)
    }

    /// Syncs settings from iCloud when changes are detected on other devices.
    @objc private func syncFromiCloud() {
        DispatchQueue.main.async {
            self.showDefaultFoodTags = self.iCloud.bool(forKey: "showDefaultFoodTags")
            self.showDefaultEmotionTags = self.iCloud.bool(forKey: "showDefaultEmotionTags")
            self.showDefaultReactionTags = self.iCloud.bool(forKey: "showDefaultReactionTags")

            // Mirror changes in UserDefaults to maintain consistency
            self.defaults.set(self.showDefaultFoodTags, forKey: "showDefaultFoodTags")
            self.defaults.set(self.showDefaultEmotionTags, forKey: "showDefaultEmotionTags")
            self.defaults.set(self.showDefaultReactionTags, forKey: "showDefaultReactionTags")
        }
    }
}
