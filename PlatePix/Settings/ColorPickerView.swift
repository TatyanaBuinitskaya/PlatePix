//
//  ColorPickerView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 17.02.2025.
//

import SwiftUI

/// A color picker view allowing users to select a theme color for the app.
/// Displays a grid of color circles, and the selection is managed by `AppColorManager`.
struct ColorPickerView: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// Controls the state of the DisclosureGroup (expanded or collapsed).
    @State private var isExpanded = false // To control the dropdown state
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // Displays a grid of color options using LazyVGrid for efficient rendering.
            LazyVGrid(columns: Array(repeating: GridItem(), count: 6)) {
                // Loop through all color cases in AppColor
                ForEach(AppColor.allCases, id: \.self) { color in
                    // Each color is displayed using the ColorCircleView component.
                    ColorCircleView(
                        color: color,
                        isSelected: colorManager.selectedColor == color,
                        action: {
                            // Update the selected color in colorManager
                            colorManager.selectedColor = color
                            isExpanded = false // Collapse after selection
                        }
                    )
                }
            }
            
        } label: {
            HStack {
                Label("Theme", systemImage: "paintpalette")
                Spacer()
                Circle()
                    .fill(colorManager.selectedColor.color)
                    .frame(width: 25, height: 25)
                // Arrow icon that rotates based on expansion state
                //                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                //                                .foregroundColor(.gray)
            }
        }
    }
}

/// A circular color option in the color picker grid.
/// Shows a checkmark if the color is currently selected.
struct ColorCircleView: View {
    /// The color option represented by this view.
    var color: AppColor
    /// Indicates whether this color is currently selected.
    var isSelected: Bool
    /// The action to perform when this color is selected.
    var action: () -> Void

    var body: some View {
        // Button that wraps the color circle and triggers the selection action.
        Button(action: action) {
            ZStack {
                // The color circle itself
                Circle()
                    .fill(color.color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle().strokeBorder(
                            isSelected ? Color(uiColor: .systemBackground) : Color.clear,
                            lineWidth: 2
                        )
                        .padding(2)
                    )
                // Checkmark overlay if the color is selected
                if  isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .font(.footnote)
                        .fontWeight(.bold)
                }
            }
        }
        .buttonStyle(PlainButtonStyle()) // No button styling
    }
}

#Preview("English") {
    ColorPickerView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    ColorPickerView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
