//
//  ContentView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI
import WidgetKit

/// The main view for displaying plates, including a motivational text, a grid of plates,
/// and floating controls for selecting which information about plates to show and adding new plates.
struct ContentView: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// An environment object that stores user preferences.
    /// This enables the app to access and modify user settings across different views.
    @EnvironmentObject var userPreferences: UserPreferences // Get it from the environment
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// A variable that counts the number of plates created
    @State var counter = 0
    // spotlight
    /// A state variable that tracks whether a selected plate should be displayed in `PlateView`.
    @State private var isShowingPlate = false
    /// A boolean that tracks whether the PDF sheet is shown.
    @State private var showPDFSheet = false
    /// The date when the last filter was applied.
    @State private var lastFilteredDate: Date = UserDefaults.standard.object(forKey: "lastFilteredDate") as? Date ?? Date.distantPast
    /// The layout of the grid used for displaying plates. It contains two flexible columns.
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 5) {
                    motivation // Displays the motivational text.

                    plateGrid // Displays the grid of plates.
                }
                .padding(.horizontal)
                floatingControls  // Displays the floating controls for interacting with the plates.
            }
            .onOpenURL(perform: openURL)
            // Set the title of the navigation bar to be dynamic based on the selected title in the dataController.
            //   .navigationTitle(LocalizedStringKey(dataController.dynamicTitle))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Plates")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedStringKey(dataController.dynamicTitle))
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .toolbar(content: ContentViewToolBar.init)
            .tint(colorManager.selectedColor.color)
            // Sets the navigation destination for Plate objects.
            .navigationDestination(for: Plate.self) { plate in
                PlateView(plate: plate) // Navigates to the PlateView when a plate is selected.
                    .environmentObject(colorManager)
                    .environmentObject(dataController)
            }
            // Navigates to a new plate view when a new plate is created.
            .navigationDestination(isPresented: $dataController.isNewPlateCreated) {
                if let newPlate = dataController.selectedPlate {
                    PlateView(plate: newPlate)
                        .environmentObject(colorManager)
                        .environmentObject(dataController)
                } else {
                    ContentView()
                        .environmentObject(userPreferences)
                }
            }
            // spotlight
            // Dynamically navigates to PlateView when a plate is selected
            .navigationDestination(isPresented: $isShowingPlate) {
                if let selectedPlate = dataController.selectedPlate {
                    PlateView(plate: selectedPlate)
                        .environmentObject(colorManager)
                        .environmentObject(dataController)
                } else {
                    ContentView()
                        .environmentObject(userPreferences)
                }
            }
            // spotlight
            // Observes changes in selectedPlate and triggers navigation
            .onChange(of: dataController.selectedPlate) {
                if dataController.selectedPlate != nil {
                    isShowingPlate = true
                } else {
                    isShowingPlate = false
                }
            }
            // Applies the selected date filter when the date changes.
            .onChange(of: dataController.selectedDate) {
                applyDateFilter()
            }
            .onAppear {
                // Filter plates for today's date if the date has changed
                let today = Calendar.current.startOfDay(for: Date())

                // Apply filter if the date has changed
                if !Calendar.current.isDate(today, inSameDayAs: lastFilteredDate) {
                    dataController.selectedFilter = Filter.filterForDate(Date())
                    lastFilteredDate = today // Save today's date to UserDefaults
                    UserDefaults.standard.set(today, forKey: "lastFilteredDate") // Save the date to UserDefaults
                }
            }
        }
    }

    /// Handles URL opening logic, specifically checking for "newPlate" in the URL.
    /// If found, it triggers the creation of a new plate.
    /// - Parameter url: The URL to be processed.
    func openURL(_ url: URL) {
        if url.absoluteString.contains("newPlate") {
            dataController.tryNewPlate()
        }
    }
}

#Preview("English") {
    ContentView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environmentObject(UserPreferences())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    ContentView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environmentObject(UserPreferences())
        .environment(\.locale, Locale(identifier: "RU"))
}

extension ContentView {
    /// A view displaying the motivational text at the top of the screen.
    private var motivation: some View {
        VStack {
            let index = loadOrGenerateMotivationIndex()
            let motivationText = Motivations.motivations[index].localizedText
            Text(motivationText)
                .font(.callout)
                .foregroundStyle(colorManager.selectedColor.color)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
        }
        .padding(.top, 0)
    }

    /// A view displaying the grid of plates with search functionality.
    private var plateGrid: some View {
        let filteredPlates = dataController.platesForSelectedFilter()
        let filterName = dataController.selectedFilter?.name ?? "selected filter"
        let filter = NSLocalizedString(filterName, comment: "")
        let date = dataController.selectedDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
        let tag = dataController.selectedFilter?.tag
        return Group {
            if filteredPlates.isEmpty {
                VStack {
                    Spacer()
                    if filterName == "Selected Date" {
                                Text("No plates on \(date)")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding()
                    } else if filterName == "All plates" {
                        Text("You don't have any plates yet")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if let tag = tag {
                        let tagTitle = NSLocalizedString(tag.tagName, tableName: dataController.tableNameForTagType(tag.type), comment: "")
                        if let selectedDate = dataController.selectedDate {
                            Text("No plates match the \(tagTitle) filter on \(date)")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            Text("No plates match the \(tagTitle) filter \(date)")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    } else {
                        if let selectedDate = dataController.selectedDate {
                            Text("No plates match the \(filter) filter on \(date)")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            Text("No plates match the \(filter) filter \(date)")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        // Iterate over the plates returned by the selected filter and display them.
                        ForEach(filteredPlates) { plate in
                            NavigationLink(value: plate) {
                                PlateBox(plate: plate) // Displays each plate in a PlateBox view.
                                    .accessibilityIdentifier("plateView")
                                    .onTapGesture {
                                        if dataController.selectedPlate == plate {
                                            dataController.selectedPlate = nil // Reset selection
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                dataController.selectedPlate = plate // Re-select after a slight delay
                                            }
                                        } else {
                                            dataController.selectedPlate = plate
                                        }
                                    }
                            }
                        }
                    }
                    // Adds search functionality to filter plates by text.
                    .searchable(
                        text: $dataController.filterText,
                        prompt: "Search in Notes"
                    )
                }
            }
        }
    }

    /// A view displaying floating controls for selecting which information about plates to show and adding new plates.
    private var floatingControls: some View {
        VStack {
            Spacer() // Pushes the controls to the bottom of the screen.
            HStack {
                shareButton
                Spacer()
                plateInfoToggles // Displays the plate info toggles.
                Spacer()
             //   addPlateButton // Displays the button to add a new plate.
                AddPlateButtonView(showingStore: $dataController.showingStore)
                        .environmentObject(dataController)
                        .environmentObject(colorManager)
                    .accessibilityIdentifier("New Plate")
                    .sheet(isPresented: $dataController.showingStore, content: StoreView.init)
            }
            
        }
        .padding()
    }

    private var shareButton: some View {
        Group {
            if dataController.selectedDate != nil {
                // Create a button to share the content as a PDF.
                Button {
                    showPDFSheet = true // Show the PDF sheet when pressed.
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .offset(y: -2)
                        .padding(10)
                        .background(Circle().fill(Color(colorManager.selectedColor.color)))
                        .padding(2)
                        .background(Circle().fill(.ultraThickMaterial))
                }
                .sheet(isPresented: $showPDFSheet) { // Shows the PDF share view as a sheet.
                    JPEGShareOneDayView()
                }
            } else {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                    .foregroundStyle(.clear)
                    .offset(y: -2)
                    .padding(10)
                    .background(Circle().fill(.clear))
                    .padding(2)
                    .background(Circle().fill(.clear))
            }
        }
    }

    /// A view displaying toggle buttons for various plate finfo.
    private var plateInfoToggles: some View {
        HStack {
            // For each info, create a toggle button with the appropriate label.
            plateInfoToggle(label: "clock", isOn: $userPreferences.showMealTime)
            plateInfoToggle(label: "HappyPDF", isOn: $userPreferences.showQuality)
            plateInfoToggle(label: "tag", isOn: $userPreferences.showTags)
            plateInfoToggle(label: "square.and.pencil", isOn: $userPreferences.showNotes)

        }
        .padding(5)
        .background(Capsule().fill(.ultraThickMaterial))
    }

    /// A toggle button for a specific info with a label and a checkbox icon.
    private func plateInfoToggle(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Button {
                isOn.wrappedValue.toggle() // Toggles the info state when the button is pressed.
            } label: {
                Group {
                    if label == "HappyPDF" {
                        Image(label)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 25)
                    } else {
                        Image(systemName: label) // Loads SF Symbol
                            .offset(y: label == "square.and.pencil" ? -2 : 0)
                    }
                }
                .foregroundStyle(isOn.wrappedValue ? Color.white : Color.gray)
                .font(.title2)
                .padding(5)
                .background {
                    Circle()
                        .fill(isOn.wrappedValue ? colorManager.selectedColor.color : .clear)
                }
            }
        }
    }

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

    /// Loads motivation index from UserDefaults, or generates a new one if missing.
    private func loadOrGenerateMotivationIndex() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix")!

        let savedIndex = defaults.integer(forKey: "lastMotivationIndex")

        // If the saved index is 0, check if it's actually a valid index or just a default value.
        if savedIndex != 0 || defaults.object(forKey: "lastMotivationIndex") != nil {
            return savedIndex
        } else {
            let newIndex = pickNewRandomMotivationIndex()
            saveMotivationIndexToDefaults(newIndex)
            return newIndex
        }
    }

    /// Saves the generated motivation index to `UserDefaults`
    private func saveMotivationIndexToDefaults(_ index: Int) {
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix")!
        defaults.set(index, forKey: "lastMotivationIndex")
        defaults.set(Date(), forKey: "lastMotivationDate")
        defaults.synchronize()
    }

    /// Picks a new random motivation index ensuring it's different from the last one.
    private func pickNewRandomMotivationIndex() -> Int {
        var newIndex: Int
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix")!

        // Repeat until a different motivation is chosen
        repeat {
            newIndex = Motivations.motivations.randomElement()!.id
        } while newIndex == defaults.integer(forKey: "lastMotivationIndex")

        return newIndex
    }
}

/// A toolbar view for the `ContentView`, allowing sharing and navigation to settings.
struct ContentViewToolBar: View {
    /// The shared `DataController` object that manages the data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
  //  @State private var isNewPlateCreated = false
    /// A boolean that tracks whether the settings screen is being navigated to.
    @State private var isNavigatingToSettings = false

    var body: some View {
        // Create a button to navigate to the settings view.
        Button {
            isNavigatingToSettings = true // Trigger navigation to settings when pressed.
        } label: {
            Image(systemName: "line.3.horizontal") // Gear icon for settings.
        }
        // Navigate to the settings view when 'isNavigatingToSettings' is true.
        .navigationDestination(isPresented: $isNavigatingToSettings) {
            SettingsView() // Navigate to the settings view.
                .environmentObject(dataController)
                .environmentObject(colorManager)
        }
    }
}
