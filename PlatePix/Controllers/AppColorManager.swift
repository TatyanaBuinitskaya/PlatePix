//
//  AppColorManager.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 17.02.2025.
//

import Foundation
import SwiftUICore

/// Enum representing the available app colors.
/// Each case corresponds to a named color in the asset catalog.
enum AppColor: String, CaseIterable {
    case redBerry, watermelonPink, orangeFruit,
         sunnyYellow, appleGreen, coolMint,
         blueSky, appleBlue, coldBlue,
         lavenderRaf, girlsPink, brightPink

    /// Maps each enum case to its corresponding Color value.
    /// - Returns: A SwiftUI Color defined in the asset catalog.
    var color: Color {
        switch self {
        case .redBerry:
            return Color("RedBerry")
        case .watermelonPink:
            return Color("WatermelonPink")
        case .orangeFruit:
            return Color("OrangeFruit")
        case .sunnyYellow:
            return Color("SunnyYellow")
        case .appleGreen:
            return Color("AppleGreen")
        case .coolMint:
            return Color("CoolMint")
        case .blueSky:
            return Color("BlueSky")
        case .appleBlue:
            return Color("AppleBlue")
        case .coldBlue:
            return Color("ColdBlue")
        case .lavenderRaf:
            return Color("LavenderRaf")
        case .girlsPink:
            return Color("GirlsPink")
        case .brightPink:
            return Color("BrightPink")
        }
    }
}

/// A manager that handles the app’s selected color theme, synchronizing across devices using iCloud
/// and persisting locally using UserDefaults with App Group support.
class AppColorManager: ObservableObject {
    /// The currently selected color. Updating this triggers saving to iCloud and UserDefaults.
    @Published var selectedColor: AppColor = .lavenderRaf {
        didSet {
            saveColor()
        }
    }
    /// Reference to iCloud key-value store.
    private let iCloud = NSUbiquitousKeyValueStore.default
    /// Shared UserDefaults for the app and extensions (e.g., widgets).
    private let userDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix")
    /// Initializes the color manager by loading the saved color and observing iCloud updates.
    init() {
        loadColor()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudUpdated),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloud
        )

        iCloud.synchronize()
    }

    /// Saves the selected color to both iCloud and shared UserDefaults.
    func saveColor() {
        iCloud.set(selectedColor.rawValue, forKey: "selectedColor")
        userDefaults?.set(selectedColor.rawValue, forKey: "selectedColor")
        iCloud.synchronize()
    }

    /// Loads the selected color from iCloud, falling back to UserDefaults if needed.
    func loadColor() {
        let iCloudValue = iCloud.string(forKey: "selectedColor")
        let localValue = userDefaults?.string(forKey: "selectedColor")

        if let rawValue = iCloudValue ?? localValue,
           let color = AppColor(rawValue: rawValue) {
            selectedColor = color
        }
    }

    /// Responds to changes in iCloud data by reloading the selected color.
    @objc private func iCloudUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadColor()
        }
    }
}
