//
//  PlateBox.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

/// A view representing a box containing a plate image with optional overlay information.
struct PlateBox: View {
    /// The environment object that provides access to shared data across views.
    @EnvironmentObject var dataController: DataController
    /// The plate object that provides data for the plate image and related information.
    @ObservedObject var plate: Plate
    /// The optional image of the plate that will be displayed.
    @State var imagePlateView: UIImage?
    /// A flag to control whether the overlay (PlateInfoOverlay) is shown or not.
    @State var showOverlay: Bool = true
    
        var body: some View {
            VStack(spacing: 3) {
                PlateImageView(
                    plate: plate,
                    imagePlateView: $imagePlateView,
                    maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 200,
                    maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 200
                )
                .overlay(
                    // Conditionally show the PlateInfoOverlay based on the showOverlay flag.
                    showOverlay ? PlateInfoOverlay(plate: plate) : nil
                )
                .frame(
                    maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 200,
                    maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 200
                )
            }
            .accessibilityIdentifier(plate.plateTitle)
        }
}

/// A view that overlays meal-related information on a plate.
struct PlateInfoOverlay: View {
    /// The environment object that provides access to shared data across views.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    @ObservedObject var userPreferences = UserPreferences.shared // Shared Preferences
    /// The plate object that provides data for the overlay.
    @ObservedObject var plate: Plate
    // State variable to control notes visibility
    @State var showNotes = false

    var body: some View {
        VStack {
            HStack {
                // Show meal time if the dataController indicates it's enabled.
                if userPreferences.showMealTime {
                    mealTimeView
                }
                Spacer()
                // Show quality if the dataController indicates it's enabled.
                if userPreferences.showQuality {
                    qualityView
                }
            }
            .padding(.horizontal, 3)
            .padding(3)
            // Set background color based on whether the meal time is shown.
            .background(userPreferences.showMealTime ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
            Spacer() // Pushes the content to the bottom
            HStack(spacing: 0) {
                // Show tags if the dataController indicates it's enabled.
                if userPreferences.showTags {
                    tagsView
                }
                if userPreferences.showNotes {
                    notesView
                }
            }
            .frame(maxHeight: 40)
            .background(
                userPreferences.showTags || userPreferences.showNotes ?
                Color.black.opacity(0.5) : Color.white.opacity(0.0))
        }
    }

        /// A computed view that shows meal time and creation date of the plate.
        private var mealTimeView: some View {
            HStack {
                let displayMealtime = plate.plateMealtime
                Text(NSLocalizedString(displayMealtime, comment: "Mealtime"))
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }

        /// A computed view that shows the quality of the plate with a star icon.
        private var qualityView: some View {
            Image(plate.quality == 0 ? "SadPDF" : (plate.quality == 1 ? "NeutralPDF" : "HappyPDF"))
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(colorManager.selectedColor.color))
                .frame(width: 18, height: 18)
                .font(.subheadline)
        }

        /// A computed view that shows the tags associated with the plate, if any.
    private var tagsView: some View {
        // Display tags or show "No Tags" if none are available.
        Text(
            plate.tags?.allObjects
                .compactMap { $0 as? Tag } // Ensure type safety
                .sorted { firstTag, secondTag in
                    let typePriority: [String] = ["My", "Food", "Emotion", "Reaction"]
                    let firstTypePriority = typePriority.firstIndex(of: firstTag.tagType) ?? Int.max
                    let secondTypePriority = typePriority.firstIndex(of: secondTag.tagType) ?? Int.max

                    if firstTypePriority == secondTypePriority {
                        // Fetch localized names for sorting in the current language
                        let firstLocalized = NSLocalizedString(
                            firstTag.tagName,
                            tableName: dataController.tableNameForTagType(firstTag.type),
                            comment: ""
                        )
                        let secondLocalized = NSLocalizedString(
                            secondTag.tagName,
                            tableName: dataController.tableNameForTagType(secondTag.type),
                            comment: ""
                        )

                        return firstLocalized.localizedStandardCompare(secondLocalized) == .orderedAscending
                    }
                    return firstTypePriority < secondTypePriority
                }
                .map { tag in
                    NSLocalizedString(
                        tag.tagName,
                        tableName: dataController.tableNameForTagType(tag.type),
                        comment: ""
                    )
                }
                .joined(separator: ", ") ?? NSLocalizedString(
                    "No Tags",
                    comment: "Fallback text when no tags are assigned"
                )
        )
        .font(.footnote)
        .minimumScaleFactor(0.4)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40)
        .padding(1)
    }

    /// A computed view that shows meal time and creation date of the plate.
    private var notesView: some View {
        HStack {
            let displayNotes = plate.plateNotes
            Text(NSLocalizedString(displayNotes, comment: "Notes"))
                .font(.footnote)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 40)
                .padding(1)
        }
    }
}

#Preview("English") {
    PlateBox(plate: .example)
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    PlateBox(plate: .example)
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
