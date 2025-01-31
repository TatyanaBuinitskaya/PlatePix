//
//  PlateBox.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

struct PlateBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    @State var imagePlateView: UIImage?
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
                showOverlay ? PlateInfoOverlay(plate: plate) : nil
                    )
            .frame(maxWidth: 200, maxHeight: 300)
        }
    }
}

struct PlateInfoOverlay: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    var body: some View {
        VStack {
            HStack {
                if dataController.showMealTime {
                    mealTimeView
                }
                Spacer()
                if dataController.showQuality {
                    qualityView
                }
            }
            .padding(.horizontal, 3)
            .padding(3)
            .background(dataController.showMealTime ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
            Spacer() // Pushes the content to the bottom
            if dataController.showTags {
                tagsView
                    .background(Color.black.opacity(0.5))
            }
        }
    }
    private var mealTimeView: some View {
        HStack {
            if let displayMealtime = dataController.mealtimeDictionary[plate.plateMealtime] {
                Text(displayMealtime) // Show the user-friendly title
                    .font(.footnote)
                    .foregroundColor(.white)
            } else {
                Text("Unknown") // Fallback if no match is found
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                .font(.footnote)
                .foregroundColor(.white)
        }
    }
    private var qualityView: some View {
        Image(systemName: "star.fill")
            .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
            .font(.subheadline)
    }
    private var tagsView: some View {
        Text(plate.tags?.allObjects.compactMap { ($0 as? Tag)?.tagName }.joined(separator: ", ") ?? "No Tags")
            .font(.footnote)
            .foregroundColor(.white)
    }
}

#Preview {
    PlateBox(plate: .example)
}
