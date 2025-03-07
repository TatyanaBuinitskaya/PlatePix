//
//  PlateBox.swift
//  MyPlates
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
                maxWidth: 200, // Different size for PlateBox
                maxHeight: 200
                )
            .overlay(
                // Conditionally show the PlateInfoOverlay based on the showOverlay flag.
                showOverlay ? PlateInfoOverlay(plate: plate) : nil
                    )
            .frame(maxWidth: 200, maxHeight: 200)
            
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
            HStack (spacing: 0) {
            // Show tags if the dataController indicates it's enabled.
                if userPreferences.showTags {
                    tagsView
                    //                    .frame(maxWidth: .infinity)
                    //                    .background((plate.tags != nil) ? Color.black.opacity(0.5) : Color.white.opacity(0.0)) // Background for the tags section
                } else {
                    Spacer()
                }
                
                Button(action: {
                    withAnimation {
                        showNotes.toggle()
                    }
                }) {
                        Image(systemName: showNotes ? "pencil.slash" :  "square.and.pencil")
                        // .background(Color(colorManager.selectedColor.color))
                            .font(.subheadline)
                            .foregroundStyle(Color(colorManager.selectedColor.color))
                            .padding(3)
                            .background(!userPreferences.showTags ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
                            .cornerRadius(5)
                    }
            }
           // .padding(!userPreferences.showTags ? 3 : 0)
            .frame(maxHeight: 40)
            .background(
               // !plate.plateTags.isEmpty ||
                userPreferences.showTags ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
         
        }
        .overlay {
            // Notes section
            if showNotes {
                Text(plate.notes ?? "No notes available")
                    .padding(3)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))  // Appearance with sliding, disappearance with fading
                    .scaleEffect(plate.notes?.count ?? 0 > 150 ? 0.7 : 1)  // Scale down if the note is too long

                    .frame(maxWidth: .infinity, alignment: .top)
            }
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
            
            // Display the plate's creation date in a shortened time format.
            Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                .font(.footnote)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
               
           
        }
    }

    /// A computed view that shows the quality of the plate with a star icon.
    private var qualityView: some View {
        Image(systemName: "star.fill")
            .foregroundStyle(plate.quality == 0 ? Color("RedBerry") : plate.quality == 1 ? Color("SunnyYellow") : Color("LeafGreen"))
            .font(.subheadline)
    }

    /// A computed view that shows the tags associated with the plate, if any.
    private var tagsView: some View {
        // Display tags or show "No Tags" if none are available.
        Text(
            plate.tags?.allObjects
                .compactMap { tag in
                    // Ensure each tag is of type Tag, then get its localized name
                    if let tag = tag as? Tag {
                        // Pass the tag's name (which should be a localization key) to NSLocalizedString
                        return NSLocalizedString(
                            tag.tagName,
                            tableName: dataController.tableNameForTagType(tag.type),
                            comment: "")
                    }
                    return nil
                }
                .joined(separator: ", ") ?? NSLocalizedString("No Tags", comment: "Fallback text when no tags are assigned")
        )
            .font(.footnote)
            .minimumScaleFactor(0.6)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
           // .lineSpacing(1) // Set line spacing for multi-line text
            .frame(maxHeight: 40)
            .padding(1)
//            .background(!plate.plateTags.isEmpty ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
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
