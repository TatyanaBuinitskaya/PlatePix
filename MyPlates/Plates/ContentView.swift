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
    /// An environment property that provides access to the system's request review action.
    /// This allows the app to prompt the user for a review at an appropriate time.
    @Environment(\.requestReview) var requestReview
    /// An environment object that stores user preferences.
    /// This enables the app to access and modify user settings across different views.
    @EnvironmentObject var userPreferences: UserPreferences // Get it from the environment
    // spotlight
    /// A state variable that tracks whether a selected plate should be displayed in `PlateView`.
    @State private var isShowingPlate = false
    /// A state variable that determines whether the store view should be shown.
    @State private var showingStore = false
   
    /// The layout of the grid used for displaying plates. It contains two flexible columns.
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    /// A computed property that checks if the user has created at least x plates.
    // If the count of plates reaches x or more, the app may prompt the user for a review.
    var shouldRequestReview: Bool {
        dataController.count(for: Plate.fetchRequest()) >= 10
    }

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
              .onAppear(perform: askForReview)
              // Set the title of the navigation bar to be dynamic based on the selected title in the dataController.
              .navigationTitle(LocalizedStringKey(dataController.dynamicTitle))
              .navigationBarTitleDisplayMode(.inline)
              .toolbar(content: ContentViewToolBar.init)
              // Sets the navigation destination for Plate objects.
              .navigationDestination(for: Plate.self) { plate in
                  PlateView(plate: plate) // Navigates to the PlateView when a plate is selected.
              }
              // Navigates to a new plate view when a new plate is created.
              .navigationDestination(isPresented: $dataController.isNewPlateCreated) {
                  if let newPlate = dataController.selectedPlate {
                      PlateView(plate: newPlate)
                  }
              }
              // spotlight
              // Dynamically navigates to PlateView when a plate is selected
              .navigationDestination(isPresented: $isShowingPlate) {
                              if let selectedPlate = dataController.selectedPlate {
                                  PlateView(plate: selectedPlate)
                              }
                          }
              // spotlight
              // Observes changes in selectedPlate and triggers navigation
              .onChange(of: dataController.selectedPlate) {
                              if dataController.selectedPlate != nil {
                                  isShowingPlate = true
                              }
                          }
//              // Applies the selected date filter when the date changes.
              .onChange(of: dataController.selectedDate) {
                  applyDateFilter()
              }
          }
      }
    func askForReview() {
        if shouldRequestReview {
            requestReview()
        }
    }
  }

#Preview("English") {
   // ContentView(dataController: .preview)
    ContentView()
        .environmentObject(DataController.preview)
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
   // ContentView(dataController: .preview)
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
            plateInfoToggle(label: "time", isOn: $userPreferences.showMealTime)
            plateInfoToggle(label: "quality", isOn: $userPreferences.showQuality)
            plateInfoToggle(label: "notes", isOn: $userPreferences.showNotes)
            plateInfoToggle(label: "tags", isOn: $userPreferences.showTags)
        }
        .padding(5)
        .background(Capsule().fill(Color.blue))
    }

    /// A toggle button for a specific info with a label and a checkbox icon.
    private func plateInfoToggle(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)  // Displays the info label.
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                isOn.wrappedValue.toggle() // Toggles the info state when the button is pressed.
               // for iOS less 17
//                if isOn.wrappedValue {
//                    UINotificationFeedbackGenerator().notificationOccurred(.success)
//                }
            } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(.white) // Makes the icon white.
                    .font(.title2) // Sets the icon size.
            }
            .sensoryFeedback(trigger: isOn.wrappedValue) { oldValue, newValue in
                if newValue {
                    .success
                } else {
                    nil
                }
            }
        }
    }

    /// A button that triggers the creation of a new plate.
    private var addPlateButton: some View {
        Button {
            tryNewPlate() 
            dataController.isNewPlateCreated = true // Marks that a new plate has been created.
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundStyle(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .sheet(isPresented: $showingStore, content: StoreView.init)

    }

    /// Attempts to create a new plate.
    /// - If the user has access to adding new plates, it proceeds normally.
    /// - If the user has reached a limit (e.g., in the free version), it triggers the store view to prompt an upgrade.
    func tryNewPlate() {
        // Calls `newPlate()` from `dataController`, which returns `false` if the user cannot add more plates.
        if dataController.newPlate() == false {
            // If the user is restricted from adding more plates, show the store to encourage upgrading.
            showingStore = true
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
