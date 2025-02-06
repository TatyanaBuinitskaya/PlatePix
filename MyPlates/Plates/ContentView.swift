//
//  ContentView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

/// The main view for displaying plates, including a motivational text, a grid of plates,
/// and floating controls for selecting which information about plates to show and adding new plates.
struct ContentView: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// A state variable that tracks whether a new plate is created.
    @State private var isNewPlateCreated = false
    /// The layout of the grid used for displaying plates. It contains two flexible columns.
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
          NavigationStack {
              ZStack {
                  VStack {
                      motivation // Displays the motivational text.
                      plateGrid // Displays the grid of plates.
                  }
                  .padding()
                  floatingControls  // Displays the floating controls for interacting with the plates.
              }
              // Set the title of the navigation bar to be dynamic based on the selected title in the dataController.
              .navigationTitle(LocalizedStringKey(dataController.dynamicTitle))
              .navigationBarTitleDisplayMode(.inline)
              .toolbar(content: ContentViewToolBar.init)
              // Sets the navigation destination for Plate objects.
              .navigationDestination(for: Plate.self) { plate in
                  PlateView(plate: plate) // Navigates to the PlateView when a plate is selected.
              }
              // Navigates to a new plate view when a new plate is created.
              .navigationDestination(isPresented: $isNewPlateCreated) {
                  if let newPlate = dataController.selectedPlate {
                      PlateView(plate: newPlate)
                  }
              }
              // Applies the selected date filter when the date changes.
              .onChange(of: dataController.selectedDate) {
                  applyDateFilter()
              }
          }
      }
  }

#Preview("English") {
    ContentView()
        .environmentObject(DataController.preview)
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    ContentView()
        .environmentObject(DataController.preview)
        .environment(\.locale, Locale(identifier: "RU"))
}

extension ContentView {
    /// A view displaying the motivational text at the top of the screen.
    private var motivation: some View {
        Text("You can become who you want")
            .font(.headline)
            .padding(.bottom, 8)
    }

    /// A view displaying the grid of plates with search functionality.
    private var plateGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                // Iterate over the plates returned by the selected filter and display them.
                ForEach(dataController.platesForSelectedFilter()) { plate in
                    NavigationLink(value: plate) {
                        PlateBox(plate: plate) // Displays each plate in a PlateBox view.
                            .accessibilityIdentifier("plateView")
                    }
                }
            }
            // Adds search functionality to filter plates by text.
            .searchable(
                text: $dataController.filterText,
                prompt: "Filter plates"
            )
        }
    }

    /// A view displaying floating controls for selecting which information about plates to show and adding new plates.
    private var floatingControls: some View {
        VStack {
            Spacer() // Pushes the controls to the bottom of the screen.
            HStack {
                plateInfoToggles // Displays the plate info toggles.
                Spacer()
                addPlateButton // Displays the button to add a new plate.
                    .accessibilityIdentifier("New Plate")
            }
        }
        .padding()
    }
    
    /// A view displaying toggle buttons for various plate finfo.
    private var plateInfoToggles: some View {
        HStack {
            // For each info, create a toggle button with the appropriate label.
            plateInfoToggle(label: "time", isOn: $dataController.showMealTime)
            plateInfoToggle(label: "quality", isOn: $dataController.showQuality)
            plateInfoToggle(label: "notes", isOn: $dataController.showNotes)
            plateInfoToggle(label: "tags", isOn: $dataController.showTags)
        }
        .padding(5)
        .background(Capsule().fill(Color.blue))
    }

    /// A toggle button for a specific info with a label and a checkbox icon.
    private func plateInfoToggle(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)  // Displays the info label.
                .font(.caption)
                .foregroundColor(.secondary)
            Button {
                isOn.wrappedValue.toggle() // Toggles the info state when the button is pressed.
            } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white) // Makes the icon white.
                    .font(.title2) // Sets the icon size.
            }
        }
    }

    /// A button that triggers the creation of a new plate.
    private var addPlateButton: some View {
        Button {
            dataController.newPlate() // Calls the method to create a new plate in the dataController.
            isNewPlateCreated = true // Marks that a new plate has been created.
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
// TODO: combine with mealtime filter too
    /// Applies the date filter to the current data.
    private func applyDateFilter() {
        if let date = dataController.selectedDate {
            if let currentFilter = dataController.selectedFilter {
                // Combine the date filter with existing quality or tag filters
                if currentFilter.quality >= 0 || currentFilter.tag != nil {
                    dataController.selectedFilter = Filter.filterForDate(date)
                        .applyingFilters(from: currentFilter)
                } else {
                    dataController.selectedFilter = Filter.filterForDate(date)
                }
            }
        } else {
            // Apply existing filters (if any) or reset to default
            dataController.selectedFilter = dataController.selectedFilter ?? .all
        }
    }
}

/// A toolbar view for the `ContentView`, allowing sharing and navigation to settings.
struct ContentViewToolBar: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    @State private var isNewPlateCreated = false
    /// A boolean that tracks whether the PDF sheet is shown.
    @State private var showPDFSheet = false
    /// A boolean that tracks whether the settings screen is being navigated to.
    @State private var isNavigatingToSettings = false

    var body: some View {
        // Create a button to share the content as a PDF.
        Button {
            showPDFSheet = true // Show the PDF sheet when pressed.
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $showPDFSheet) { // Shows the PDF share view as a sheet.
            PDFSheetShareView()
        }

        // Create a button to navigate to the settings view.
        Button {
            isNavigatingToSettings = true // Trigger navigation to settings when pressed.
        } label: {
            Image(systemName: "gear") // Gear icon for settings.
        }
        // Navigate to the settings view when 'isNavigatingToSettings' is true.
        .navigationDestination(isPresented: $isNavigatingToSettings) {
            SettingsView() // Navigate to the settings view.
        }
    }
}
