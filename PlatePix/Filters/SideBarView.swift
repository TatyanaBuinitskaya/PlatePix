//
//  SideBarView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI

/// A view representing a sidebar containing various filters
/// to refine plate data based on date, tags, mealtime, and quality.
struct SideBarView: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The current color scheme of the app (light or dark mode).
    @Environment(\.colorScheme) var colorScheme
    /// The view model responsible for managing the state and logic of this view.
    @StateObject private var viewModel: ViewModel
    /// State variable to control the presentation of the calendar sheet.
    @State private var showCalendarSheet = false
    /// State variables to control the visibility of various filter lists.
    @State private var showTagFilterList = false
    /// Controls the visibility of the food-related tag filter list.
    @State private var showFoodTagFilterList = false
    /// Controls the visibility of the reaction-based tag filter list.
    @State private var showReactionTagFilterList = false
    /// Controls the visibility of the emotion-based tag filter list.
    @State private var showEmotionTagFilterList = false
    /// A dictionary to track whether each tag type filter should be shown.
    @State private var showTagTypeFilters: [String: Bool] = [:]
    /// State variable to control the visibility of the mealtime filter list.
    @State private var showMealtimeFilterList = false
    /// Controls the visibility of an alert indicating that no tags have been added yet.
    @State private var showAlertNoTagsYet = false

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
            Section("Filter by Date") {
                dateFilterButton(
                    label: LocalizedStringKey("All Plates"),
                    systemImage: "calendar",
                    plateCount: viewModel.allPlatesCount
                ) {
                    // Set filter to "All Plates"
                    viewModel.dataController.selectedFilter = Filter.all
                    viewModel.dataController.selectedDate = nil
                }
                dateFilterButton(
                    label: LocalizedStringKey("Today"),
                    systemImage: "1.square",
                    plateCount: viewModel.dataController.countSelectedDatePlates(for: Date())
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
                        Label(NSLocalizedString("Select a Date", comment: ""), systemImage: "calendar.badge.plus")
                            .layoutPriority(1) // Gives higher priority to this text
                            .lineLimit(1) // Ensures it stays in one line
                            .fixedSize(horizontal: true, vertical: false) // Prevents truncation
                        Text("(\(selectedDate))")
                            .font(.caption) // Smaller font for date
                            .minimumScaleFactor(0.6) // Allows shrinking
                            .lineLimit(1) // Ensures one line
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary.opacity(0.6))
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                }
            }

            // Section for tag-based filters.
            Section("Filter by Tag") {
                expandableFilterSection(
                    label: LocalizedStringKey("Select a Tag"),
                    systemImage: "tag",
                    isExpanded: $showTagFilterList,
                    items: viewModel.generateTagFilters(colorScheme: colorScheme),
                    colorManager: colorManager,
                    showAlertNoTags: $showAlertNoTagsYet
                )
            }

            // Section for mealtime filters.
            Section("Filter by Mealtime") {
                expandableFilterSection(
                    label: LocalizedStringKey("Select a Mealtime"),
                    systemImage: "clock",
                    isExpanded: $showMealtimeFilterList,
                    items: mealtimeFilters.map { filter in
                        NavigationLink(value: filter) {
                            let mealtime = filter.mealtime ?? ""
                            let plateCount = viewModel.countMealtimePlates(for: mealtime)
                            Text(NSLocalizedString(filter.name, comment: "Mealtime"))
                                .badge("\(plateCount)")
                        }
                    },
                    colorManager: colorManager,
                    showAlertNoTags: $showAlertNoTagsYet
                )
            }

            // Section for quality filters.
            Section("Filter by Food Quality") {

                ForEach(qualityFilters) { filter in
                    NavigationLink(value: filter) {
                        qualityFilterRow(filter: filter)
                    }
                }
                // Display the summary text for quality filter results.
                qualitySummaryText(
                    goodCount: viewModel.countQualityPlates(for: 2),
                    averageCount: viewModel.countQualityPlates(for: 1),
                    badCount: viewModel.countQualityPlates(for: 0)
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
    /// A helper function to create a row for each quality filter.
    @ViewBuilder
    private func qualityFilterRow(filter: Filter) -> some View {
        HStack {
            // Display the icon for the filter with color based on quality.
            Image(filter.icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(colorManager.selectedColor.color))
                .frame(width: 23, height: 23)
                .font(.title3)

            Text(LocalizedStringKey(filter.name))
                .badge("\(viewModel.countQualityPlates(for: filter.quality))")
        }
    }

    /// A helper function to display the summary text for the quality filters.
    @ViewBuilder
    private func qualitySummaryText(goodCount: Int, averageCount: Int, badCount: Int) -> some View {
        // Display different messages depending on the counts of good, average, and bad plates.
        if goodCount > badCount && goodCount > averageCount {
            Text("You're doing amazing! Keep up the great work with your healthy choices!")
                .font(.callout)
                .foregroundStyle(Color(colorManager.selectedColor.color))
                .fontDesign(.rounded)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        } else if badCount > goodCount && badCount > averageCount {
            Text("You might want to focus on healthier options to feel your best!")
                .font(.callout)
                .foregroundStyle(Color(colorManager.selectedColor.color))
                .fontDesign(.rounded)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        } else {
            Text("You're maintaining a good balance! Keep making mindful choices!")
                .font(.callout)
                .foregroundStyle(Color(colorManager.selectedColor.color))
                .fontDesign(.rounded)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        }
    }
}

#Preview("English") {
    SideBarView(dataController: .preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
        }

#Preview("Russian") {
    SideBarView(dataController: .preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
        }

/// Creates a button view for a date filter that displays the filter label, a badge with plate count, and an arrow to indicate selection.
/// - Parameters:
///   - label: The label of the filter button (e.g., "All plates" or "Today").
///   - systemImage: The system image to be used for the button's icon (e.g., "calendar").
///   - plateCount: The number of plates associated with this filter.
///   - action: The action to be performed when the button is pressed. This is passed as a closure.
@ViewBuilder
private func dateFilterButton(
    label: LocalizedStringKey,
    systemImage: String,
    plateCount: Int,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        HStack {
            // Display the label with the system image, followed by a badge showing the plate count.
            Label(label, systemImage: systemImage)
                .badge("\(plateCount)") // Adds a badge showing the plate count.
            // Chevron icon to indicate that this is a button that leads to further options.
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary.opacity(0.6))
                .font(.footnote)
                .fontWeight(.bold)
        }
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
    label: LocalizedStringKey,
    systemImage: String,
    isExpanded: Binding<Bool>,
    items: [some View],
    colorManager: AppColorManager, // Pass colorManager explicitly as a parameter
    showAlertNoTags: Binding<Bool>
) -> some View {

    Button {
        // Toggle the expanded state with animation when the section header is tapped.
        if items.isEmpty {
            showAlertNoTags.wrappedValue = true
        } else {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        }
    } label: {
        HStack {
            // Display the system image and label for the section header.
            Image(systemName: systemImage)
                .foregroundStyle(colorManager.selectedColor.color)
                .font(.title3)
            Text(label) // The label text of the section.
            Spacer() // Pushes the chevron icon to the right of the label.
            // Chevron icon indicating the expanded or collapsed state.
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded.wrappedValue ? 180 : 0)) // Rotates the chevron based on expansion state.
                .foregroundStyle(.secondary.opacity(0.6))
                .font(.footnote)
                .fontWeight(.bold)
                .animation(.easeInOut(duration: 0.3), value: isExpanded.wrappedValue) // Adds smooth rotation animation.
        }
    }
    .alert("No tags available", isPresented: showAlertNoTags) {
        Button("OK", role: .cancel) { }

        } message: {
            Text("You need to add at least one tag before filtering.")
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
        .sheet(isPresented: $showAwards) {
            AwardsView()
                .presentationDetents([.height(500)])
        }
    }
}
