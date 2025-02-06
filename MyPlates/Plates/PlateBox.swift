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
    var showOverlay: Bool = true

    var body: some View {
        VStack(spacing: 3) {
            PlateImageView(
                plate: plate,
                imagePlateView: $imagePlateView,
                maxWidth: 200, // Different size for PlateBox
                maxHeight: 300
                )
            .overlay(
                // Conditionally show the PlateInfoOverlay based on the showOverlay flag.
                showOverlay ? PlateInfoOverlay(plate: plate) : nil
                    )
            .frame(maxWidth: 200, maxHeight: 300)
        }
        .accessibilityIdentifier(plate.plateTitle)
    }
}

/// A view that overlays meal-related information on a plate.
struct PlateInfoOverlay: View {
    /// The environment object that provides access to shared data across views.
    @EnvironmentObject var dataController: DataController
    /// The plate object that provides data for the overlay.
    @ObservedObject var plate: Plate

    var body: some View {
        VStack {
            HStack {
                // Show meal time if the dataController indicates it's enabled.
                if dataController.showMealTime {
                    mealTimeView
                }
                Spacer()
                // Show quality if the dataController indicates it's enabled.
                if dataController.showQuality {
                    qualityView
                }
            }
            .padding(.horizontal, 3)
            .padding(3)
            // Set background color based on whether the meal time is shown.
            .background(dataController.showMealTime ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
            Spacer() // Pushes the content to the bottom
            // Show tags if the dataController indicates it's enabled.
            if dataController.showTags {
                tagsView
                    .background(Color.black.opacity(0.5)) // Background for the tags section
            }
        }
    }

    /// A computed view that shows meal time and creation date of the plate.
    private var mealTimeView: some View {
        HStack {
            if let displayMealtime = dataController.mealtimeDictionary[plate.plateMealtime] {
                Text(displayMealtime)
                    .font(.footnote)
                    .foregroundColor(.white)
            } else {
                Text("Unknown") 
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            // Display the plate's creation date in a shortened time format.
            Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                .font(.footnote)
                .foregroundColor(.white)
        }
    }

    /// A computed view that shows the quality of the plate with a star icon.
    private var qualityView: some View {
        Image(systemName: "star.fill")
            .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
            .font(.subheadline)
    }

    /// A computed view that shows the tags associated with the plate, if any.
    private var tagsView: some View {
        // Display tags or show "No Tags" if none are available.
        Text(plate.tags?.allObjects.compactMap { ($0 as? Tag)?.tagName }.joined(separator: ", ") ?? "No Tags")
            .font(.footnote)
            .foregroundColor(.white)
    }
}

#Preview {
    PlateBox(plate: .example)
}
