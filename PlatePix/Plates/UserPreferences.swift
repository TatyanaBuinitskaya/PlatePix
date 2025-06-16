//
//  UserPreferences.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 07.02.2025.
//

import Foundation

/// A singleton class that manages user preferences for UI settings, saving them to both local UserDefaults and iCloud Key-Value store.
/// This class ensures preferences are synchronized across devices using iCloud, while also providing local storage on the current device.
class UserPreferences: ObservableObject {
    static let shared = UserPreferences() // Singleton instance to manage preferences globally.
    // Local UserDefaults for storing preferences on the current device
    private let localDefaults = UserDefaults.standard
    // iCloud Key-Value Store for syncing preferences across devices
    private let iCloud = NSUbiquitousKeyValueStore.default
    /// A Boolean value that determines whether the meal time should be shown in the UI.
    /// Changes are saved to both UserDefaults and iCloud.
    @Published var showMealTime: Bool {
        didSet {
            // Save to local UserDefaults and iCloud when the preference changes
            localDefaults.set(showMealTime, forKey: "showMealTime")
            iCloud.set(showMealTime, forKey: "showMealTime")
        }
    }
    /// A Boolean value that determines whether the food quality should be shown in the UI.
    /// Changes are saved to both UserDefaults and iCloud.
    @Published var showQuality: Bool {
        didSet {
            // Save to local UserDefaults and iCloud when the preference changes
            localDefaults.set(showQuality, forKey: "showQuality")
            iCloud.set(showQuality, forKey: "showQuality")
        }
    }
    /// A Boolean value that determines whether tags should be shown in the UI.
    /// Changes are saved to both UserDefaults and iCloud.
    @Published var showTags: Bool {
        didSet {
            // Save to local UserDefaults and iCloud when the preference changes
            localDefaults.set(showTags, forKey: "showTags")
            iCloud.set(showTags, forKey: "showTags")
        }
    }
    /// A Boolean value that determines whether notes should be shown in the UI.
    /// Changes are saved to both UserDefaults and iCloud.
    @Published var showNotes: Bool {
        didSet {
            // Save to local UserDefaults and iCloud when the preference changes
            localDefaults.set(showNotes, forKey: "showNotes")
            iCloud.set(showNotes, forKey: "showNotes")
        }
    }

    /// Initializes the `UserPreferences` object.
    /// It attempts to load the preferences from iCloud first. If no iCloud value is found, it falls back to local UserDefaults.
    init() {
        // Try to load preferences from iCloud first. If not available, fall back to UserDefaults.
        self.showMealTime = iCloud.object(forKey: "showMealTime") as? Bool ?? localDefaults.bool(forKey: "showMealTime")
        self.showQuality = iCloud.object(forKey: "showQuality") as? Bool ?? localDefaults.bool(forKey: "showQuality")
        self.showTags = iCloud.object(forKey: "showTags") as? Bool ?? localDefaults.bool(forKey: "showTags")
        self.showNotes = iCloud.object(forKey: "showNotes") as? Bool ?? localDefaults.bool(forKey: "showNotes")

        // Listen for changes from iCloud, ensuring the preferences are synchronized across devices.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(syncFromiCloud),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloud
        )

        // Synchronize the iCloud data, ensuring that the latest values are available.
        iCloud.synchronize()
    }

    /// Syncs preferences from iCloud when changes are detected.
    /// This ensures that any updates made on other devices are reflected on the current device.
    @objc private func syncFromiCloud() {
        DispatchQueue.main.async {
            // Load the latest preferences from iCloud and update the published properties.
            self.showMealTime = self.iCloud.bool(forKey: "showMealTime")
            self.showQuality = self.iCloud.bool(forKey: "showQuality")
            self.showTags = self.iCloud.bool(forKey: "showTags")
            self.showNotes = self.iCloud.bool(forKey: "showNotes")
        }
    }
}
