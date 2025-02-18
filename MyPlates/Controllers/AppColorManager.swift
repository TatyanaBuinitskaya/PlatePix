//
//  AppColorManager.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 17.02.2025.
//

import Foundation
import SwiftUICore

/// Enum representing the available app colors.
/// Each case corresponds to a named color in the asset catalog.
enum AppColor: String, CaseIterable {
    case redBerry, watermelonPink, orangeFruit, sunnyYellow, appleGreen, leafGreen, coolMint, blueSky, appleBlue, coldBlue, purpleBluberry, girlsPink
    
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
        case .leafGreen:
            return Color("LeafGreen")
        case .coolMint:
            return Color("CoolMint")
        case .blueSky:
            return Color("BlueSky")
        case .appleBlue:
            return Color("AppleBlue")
        case .coldBlue:
            return Color("ColdBlue")
        case .purpleBluberry:
            return Color("PurpleBluberry")
        case .girlsPink:
            return Color("GirlsPink")
        }
    }
}

/// Manages the selected color for the app, making it observable by SwiftUI views.
/// This allows dynamic color updates across the app.
class AppColorManager: ObservableObject {
    /// The currently selected color.
    /// Updating this property triggers UI updates and saves the selection to UserDefaults.
    @Published var selectedColor: AppColor = .watermelonPink {
        didSet {
            saveColor() // Save the new selection when it changes.
        }
    }

    /// Initializes the color manager and loads the saved color.
    init() {
        loadColor()
    }

    /// Saves the selected color to UserDefaults using App Groups.
        /// This allows the color to be shared with widgets and other app extensions.
    func saveColor() {
        if let groupDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates") {
            groupDefaults.set(selectedColor.rawValue, forKey: "selectedColor")
        }
    }
    
    /// Loads the previously selected color from UserDefaults.
    func loadColor() {
        if let groupDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates"),
           let rawValue = groupDefaults.string(forKey: "selectedColor"),
           let color = AppColor(rawValue: rawValue) {
            selectedColor = color
        }
    }
}

