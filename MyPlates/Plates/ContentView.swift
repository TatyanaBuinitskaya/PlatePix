//
//  ContentView.swift
//  MyPlates
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
    /// An environment property that provides access to the system's request review action.
    /// This allows the app to prompt the user for a review at an appropriate time.
    @Environment(\.requestReview) var requestReview
    /// A variable that counts the number of plates created
    @State var counter = 0
    /// An environment object that stores user preferences.
    /// This enables the app to access and modify user settings across different views.
    @EnvironmentObject var userPreferences: UserPreferences // Get it from the environment
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    // spotlight
    /// A state variable that tracks whether a selected plate should be displayed in `PlateView`.
    @State private var isShowingPlate = false
    /// A state variable that determines whether the store view should be shown.
    @State private var showingStore = false
    /// A boolean that tracks whether the PDF sheet is shown.
    @State private var showPDFSheet = false
   
    /// The layout of the grid used for displaying plates. It contains two flexible columns.
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    /// A computed property that checks if the user has created at least x plates.
    // If the count of plates reaches x or more, the app may prompt the user for a review.
    var shouldRequestReview: Bool {
        dataController.count(for: Plate.fetchRequest()) >= 10
    }
   
    var body: some View {
          NavigationStack {
            
              ZStack {
                      VStack (spacing: 5) {
                          motivation // Displays the motivational text.
                          
                          plateGrid // Displays the grid of plates.
                  }
                  .padding(.horizontal)
                  floatingControls  // Displays the floating controls for interacting with the plates.
              }
              .onOpenURL(perform: openURL)
//              .userActivity(newPlateActivity) { activity in
//                  activity.isEligibleForPrediction = true
//                  activity.title = "New Plate"
//              }
//              .onContinueUserActivity(newPlateActivity, perform: resumeActivity)
              // Set the title of the navigation bar to be dynamic based on the selected title in the dataController.
              .navigationTitle(LocalizedStringKey(dataController.dynamicTitle))
              .navigationBarTitleDisplayMode(.inline)
              .toolbar(content: ContentViewToolBar.init)
              .tint(colorManager.selectedColor.color)
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
              // Applies the selected date filter when the date changes.
              .onChange(of: dataController.selectedDate) {
                  applyDateFilter()
              }
          }
         

      }

    /// Checks if the review request criteria are met and triggers the review prompt.
    func askForReview() {
        if shouldRequestReview {
            requestReview()
        }
    }

    /// Handles URL opening logic, specifically checking for "newPlate" in the URL.
        /// If found, it triggers the creation of a new plate.
        /// - Parameter url: The URL to be processed.
    func openURL(_ url: URL) {
        if url.absoluteString.contains("newPlate") {
            tryNewPlate()
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
             //   .foregroundStyle(Color(uiColor: .systemBackground))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
             //   .padding(5)
              //  .background(colorManager.selectedColor.color)
                .cornerRadius(8)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
        }
      //  .padding(.top, 0)
        .padding(.top, 0)
    }

    /// A view displaying the grid of plates with search functionality.
    private var plateGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
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
                prompt: "Search in Notes"
            )
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
                addPlateButton // Displays the button to add a new plate.
                    .accessibilityIdentifier("New Plate")
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
                    PDFShareOneDayView()
                  //  PDFSheetShareView()
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
            plateInfoToggle(label: "star", isOn: $userPreferences.showQuality)
            plateInfoToggle(label: "tag", isOn: $userPreferences.showTags)
        }
        .padding(5)
        .background(Capsule().fill(.ultraThickMaterial))
    }

    /// A toggle button for a specific info with a label and a checkbox icon.
    private func plateInfoToggle(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Button {
                isOn.wrappedValue.toggle() // Toggles the info state when the button is pressed.
          //  MARK: haptics
               // for iOS less 17
//                if isOn.wrappedValue {
//                    UINotificationFeedbackGenerator().notificationOccurred(.success)
//                }
             //   let generator = UIImpactFeedbackGenerator(style: .medium)
               //                generator.impactOccurred() // Medium haptic for renaming
            } label: {
                Image(systemName: label)
                    .foregroundStyle(isOn.wrappedValue ? Color.white : Color.gray)
                    .font(.title2)
                    .padding(5)
                    .background {
                        Circle()
                            .fill(isOn.wrappedValue ? colorManager.selectedColor.color : .clear)
                    }
            }
//            .sensoryFeedback(trigger: isOn.wrappedValue) { oldValue, newValue in
//                if newValue {
//                    .success
//                } else {
//                    nil
//                }
//            }
        }
    }

    /// A button that triggers the creation of a new plate.
    private var addPlateButton: some View {
        Button {
            tryNewPlate()
            dataController.isNewPlateCreated = true // Marks that a new plate has been created.
            counter += 1
            print("Counter updated: \(counter)")

            if counter == 20 || counter.isMultiple(of: 300) {
                print("Requesting review")

                requestReview()
            }
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .foregroundStyle(.white)
                .padding(10)
                .background(Circle().fill(Color(colorManager.selectedColor.color)))
                .padding(2)
                .background(Circle().fill(.ultraThickMaterial))
             
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

    /// Loads motivation index from UserDefaults, or generates a new one if missing.
    private func loadOrGenerateMotivationIndex() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates")!
        
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
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates")!
        defaults.set(index, forKey: "lastMotivationIndex")
        defaults.set(Date(), forKey: "lastMotivationDate")
        defaults.synchronize()
    }
    
    /// Picks a new random motivation index ensuring it's different from the last one.
    private func pickNewRandomMotivationIndex() -> Int {
        var newIndex: Int
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates")!

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
    @State private var isNewPlateCreated = false
   
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
        }
    }
}
