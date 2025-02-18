//
//  SideBarView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI

/// A view representing a sidebar containing various filters to refine plate data based on date, tags, mealtime, and quality.
struct SideBarView: View {
//    /// A view representing a sidebar containing various filters to refine plate data based on date, tags, mealtime, and quality.
//    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The view model responsible for managing the state and logic of this view.
    @StateObject private var viewModel: ViewModel
    /// State variable to control the presentation of the calendar sheet.
    @State private var showCalendarSheet = false
    /// State variables to control the visibility of various filter lists.
    @State private var showTagFilterList = false
    @State private var showMonthTagFilterList = false
    @State private var showFoodTagFilterList = false
    @State private var showReactionTagFilterList = false
    @State private var showEmotionTagFilterList = false
    /// A dictionary to track whether each tag type filter should be shown.
    @State private var showTagTypeFilters: [String: Bool] = [:]
    /// A set to track which filter groups are expanded.
    @State private var expandedGroups: Set<String> = []
    /// State variable to control the visibility of the mealtime filter list.
    @State private var showMealtimeFilterList = false
    
    /// A predefined set of mealtime filters for the sidebar.
    let mealtimeFilters: [Filter] = [.breakfast, .morningSnack, .lunch, .daySnack, .dinner, .eveningSnack, .anytimeMeal]
    let qualityFilters: [Filter] = [.healthy, .moderate, .unhealthy]
    /// A predefined set of quality filters for the sidebar.

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {

            // Section for date-based filters.
            Section("Date Filters") {
                dateFilterButton(
                    label: "All plates",
                    systemImage: "calendar",
                    plateCount: viewModel.allPlatesCount,
                    accessibilityHint: "\(viewModel.allPlatesCount) plates"
                ) {
                    // Set filter to "All Plates"
                    viewModel.dataController.selectedFilter = Filter.all
                    viewModel.dataController.selectedDate = nil
                }
                dateFilterButton(
                    label: "Today",
                    systemImage: "1.square",
                    plateCount: viewModel.dataController.countSelectedDatePlates(for: Date()),
                    accessibilityHint: "\(viewModel.dataController.countSelectedDatePlates(for: Date())) plates"
                ) {
                    // Set filter to today's date
                    viewModel.dataController.selectedFilter = Filter.filterForDate(Date())
                    viewModel.dataController.selectedDate = Date()
                }
                Button {
                    // Show calendar sheet to select a custom date
                    showCalendarSheet = true
                } label: {
                    HStack {
                        let selectedDate = viewModel.dataController.formattedDate(viewModel.dataController.selectedDate ?? Date())
                        Label("Select date" + " (" + selectedDate + ")", systemImage: "calendar.badge.plus")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
            }

            // Section for tag-based filters.
            Section("Tags") {
                expandableFilterSection(
                    label: "Choose a tag filter",
                    systemImage: "tag",
                    isExpanded: $showTagFilterList,
                    items: viewModel.generateTagFilters(),
                    colorManager: colorManager
                )
            }

            // Section for mealtime filters.
            Section("Mealtime filters") {
                expandableFilterSection(
                    label: "Choose a Mealtime filter",
                    systemImage: "clock",
                    isExpanded: $showMealtimeFilterList,
                    items: mealtimeFilters.map { filter in
                        NavigationLink(value: filter) {
                            let mealtime = filter.mealtime ?? ""
                            let plateCount = viewModel.countMealtimePlates(for: mealtime)
                            Text(LocalizedStringKey(filter.name))
                                .badge("\(plateCount)")
                                .accessibilityLabel(filter.name)
                                .accessibilityHint("\(plateCount) plates")
                        }
                    },
                    colorManager: colorManager
                )
            }

            // Section for quality filters.
            Section("Quality filters") {
                QualityFiltersSection(
                    qualityFilters: qualityFilters,
                    countQualityPlates: viewModel.countQualityPlates(for:)
                )
            }
        }
        .accentColor(colorManager.selectedColor.color)
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: SideBarViewToolBar.init)
        .sheet(isPresented: $showCalendarSheet, content: CalendarSheetView.init)
        .onAppear {
            // Initialize any missing tag type filters when the view appears.
            for tagType in viewModel.dataController.availableTagTypes where showTagTypeFilters[tagType] == nil {
                showTagTypeFilters[tagType] = false
            }
        }
    }

  
}

#Preview {
    SideBarView(dataController: .preview)
   }

/// Creates a button view for a date filter that displays the filter label, a badge with plate count, and an arrow to indicate selection.
/// - Parameters:
///   - label: The label of the filter button (e.g., "All plates" or "Today").
///   - systemImage: The system image to be used for the button's icon (e.g., "calendar").
///   - plateCount: The number of plates associated with this filter.
///   - accessibilityHint: A description for accessibility purposes (e.g., "5 plates").
///   - action: The action to be performed when the button is pressed. This is passed as a closure.
@ViewBuilder
private func dateFilterButton(
    label: String,
    systemImage: String,
    plateCount: Int,
    accessibilityHint: String,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        HStack {
            // Display the label with the system image, followed by a badge showing the plate count.
            Label(label, systemImage: systemImage)
                .badge("\(plateCount)") // Adds a badge showing the plate count.
            // Chevron icon to indicate that this is a button that leads to further options.
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .font(.footnote)
        }
        // Makes the button accessible with the label and hint for users with screen readers.
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityHint(accessibilityHint)
    }
}

/// Creates a button view that allows expanding or collapsing a filter section. The expansion/collapse is animated and displays items when expanded.
/// - Parameters:
///   - label: The label for the filter section (e.g., "Tags", "Quality").
///   - systemImage: The system image for the section (e.g., "tag").
///   - isExpanded: A binding to track whether the section is expanded or collapsed.
///   - items: A list of views (items) to be shown when the section is expanded. This can be dynamic content such as filter options.
@ViewBuilder
private func expandableFilterSection(
    label: String,
    systemImage: String,
    isExpanded: Binding<Bool>,
    items: [some View],
    colorManager: AppColorManager // Pass colorManager explicitly as a parameter
) -> some View {

    Button {
        // Toggle the expanded state with animation when the section header is tapped.
        withAnimation {
            isExpanded.wrappedValue.toggle()
        }
    } label: {
        HStack {
            // Display the system image and label for the section header.
            Image(systemName: systemImage)
                .foregroundStyle(colorManager.selectedColor.color) 
            Text(label) // The label text of the section.
            Spacer() // Pushes the chevron icon to the right of the label.
            // Chevron icon indicating the expanded or collapsed state.
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded.wrappedValue ? 180 : 0)) // Rotates the chevron based on expansion state.
                .foregroundStyle(.secondary)
                .font(.footnote)
                .animation(.easeInOut(duration: 0.3), value: isExpanded.wrappedValue) // Adds smooth rotation animation.
        }
    }
    // If the section is expanded, show the items inside the section.
    if isExpanded.wrappedValue {
        // Use `ForEach` to render the items inside the expanded section.
        ForEach(items.indices, id: \.self) { index in
            // Each item is shown with a move-and-opacity transition when the section is expanded.
            items[index]
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

/// A section in the sidebar to display and handle quality-based filters.
/// - Properties:
///   - qualityFilters: The available quality filters to be displayed in the section.
///   - countQualityPlates: A function that takes a quality value (e.g., 0, 1, or 2) and returns the count of plates matching that quality.
struct QualityFiltersSection: View {
    let qualityFilters: [Filter]
    let countQualityPlates: (Int) -> Int
    
    var body: some View {
        // Iterate over the available quality filters and create navigation links.
        Section("Quality filters") {
            ForEach(qualityFilters) { filter in
                NavigationLink(value: filter) {
                    qualityFilterRow(filter: filter)
                }
            }
            // Display the summary text for quality filter results.
            qualitySummaryText(
                goodCount: countQualityPlates(2),
                averageCount: countQualityPlates(1),
                badCount: countQualityPlates(0)
            )
        }
    }

    /// A helper function to create a row for each quality filter.
    @ViewBuilder
    private func qualityFilterRow(filter: Filter) -> some View {
        HStack {
            // Display the icon for the filter with color based on quality.
            Image(systemName: filter.icon)
                .foregroundStyle(
                    filter.quality == 0 ? Color("RedBerry") :
                    filter.quality == 1 ? Color("SunnyYellow") : Color("LeafGreen")
                )
            Text(LocalizedStringKey(filter.name))
                .badge("\(countQualityPlates(filter.quality))")
        }
        .accessibilityElement()
        .accessibilityLabel(filter.name)
        .accessibilityHint("\(countQualityPlates(filter.quality)) plates")
    }

    /// A helper function to display the summary text for the quality filters.
    @ViewBuilder
    private func qualitySummaryText(goodCount: Int, averageCount: Int, badCount: Int) -> some View {
        // Display different messages depending on the counts of good, average, and bad plates.
        if goodCount > badCount && goodCount > averageCount {
            Text("You're doing great! Keep up with the healthy choices!")
                .foregroundStyle(Color("LeafGreen"))
                .italic()
        } else if badCount > goodCount && badCount > averageCount {
            Text("You may want to focus on eating healthier.")
                .foregroundStyle(Color("RedBerry"))
                .italic()
        } else {
            Text("You're balancing your choices well!")
                .foregroundStyle(Color("SunnyYellow"))
                .italic()
        }
    }
}

/// A toolbar view for the sidebar with a button to show the awards sheet.
/// - Properties:
///   - showAwards: A state variable that tracks whether the awards sheet is displayed or not.
struct SideBarViewToolBar: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// Controls the visibility of the awards screen.
    @State private var showAwards = false

    var body: some View {
        Button {
            // Toggle showing the awards sheet when pressed.
            showAwards.toggle()
        } label: {
            // Label for the button with an icon for "Show awards."
            Label("Show awards", systemImage: "rosette")
        }
        .tint(colorManager.selectedColor.color)
        .sheet(isPresented: $showAwards, content: AwardsView.init)

    }
}
