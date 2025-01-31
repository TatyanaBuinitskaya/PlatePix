//
//  SideBarView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var dataController: DataController
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    @State private var showCalendarSheet = false
    @State private var showTagFilterList = false
    @State private var showMonthTagFilterList = false
    @State private var showFoodTagFilterList = false
    @State private var showReactionTagFilterList = false
    @State private var showEmotionTagFilterList = false
    @State private var showTagTypeFilters: [String: Bool] = [:]
    @State private var expandedGroups: Set<String> = [] // Track expanded groups
    @State private var showMealtimeFilterList = false
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    let mealtimeFilters: [Filter] = [.breakfast, .morningSnack, .lunch, .daySnack, .dinner, .eveningSnack, .anytimeMeal]
    let qualityFilters: [Filter] = [.healthy, .moderate, .unhealthy]
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Date Filters") {
                dateFilterButton(
                    label: "All plates",
                    systemImage: "calendar",
                    plateCount: dataController.allPlatesCount,
                    accessibilityHint: "\(dataController.allPlatesCount) plates"
                ) {
                    dataController.selectedFilter = Filter.all
                    dataController.selectedDate = nil
                }
                dateFilterButton(
                    label: "Today",
                    systemImage: "1.square",
                    plateCount: dataController.countSelectedDatePlates(for: Date()),
                    accessibilityHint: "\(dataController.countSelectedDatePlates(for: Date())) plates"
                ) {
                    dataController.selectedFilter = Filter.filterForDate(Date())
                    dataController.selectedDate = Date()
                }
                Button {
                    showCalendarSheet = true
                } label: {
                    HStack {
                        let selectedDate = dataController.formattedDate(dataController.selectedDate ?? Date())
                        Label("Select date" + " (" + selectedDate + ")", systemImage: "calendar.badge.plus")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
            }
            Section("Tags") {
                expandableFilterSection(
                    label: "Choose a tag filter",
                    systemImage: "tag",
                    isExpanded: $showTagFilterList,
                    items: generateTagFilters()
                )
            }
            Section("Mealtime filters") {
                expandableFilterSection(
                    label: "Choose a Mealtime filter",
                    systemImage: "clock",
                    isExpanded: $showMealtimeFilterList,
                    items: mealtimeFilters.map { filter in
                        NavigationLink(value: filter) {
                            let mealtime = filter.mealtime ?? ""
                            let plateCount = dataController.countMealtimePlates(for: mealtime)
                            Text(LocalizedStringKey(filter.name))
                                .badge("\(plateCount)")
                                .accessibilityLabel(filter.name)
                                .accessibilityHint("\(plateCount) plates")
                        }
                    }
                )
            }
            Section("Quality filters") {
                QualityFiltersSection(
                    qualityFilters: qualityFilters,
                    countQualityPlates: dataController.countQualityPlates(for:)
                )
            }
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: SideBarViewToolBar.init)
        .sheet(isPresented: $showCalendarSheet, content: CalendarSheetView.init)
//        .onAppear {
//            for tagType in dataController.availableTagTypes {
//                   if showTagTypeFilters[tagType] == nil {
//                       showTagTypeFilters[tagType] = false
//                   }
//               }
//        }
        .onAppear {
            for tagType in dataController.availableTagTypes where showTagTypeFilters[tagType] == nil {
                showTagTypeFilters[tagType] = false
            }
        }
    }
    private func generateTagFilters() -> [AnyView] {
        let groupedTags = Dictionary(grouping: tagFilters) { $0.tag?.type ?? "Other" }
       // return groupedTags.keys.sorted().flatMap { type -> [AnyView] in
        return groupedTags.keys.sorted(by: dataController.sortTags).flatMap { type -> [AnyView] in
            var views: [AnyView] = []
            // Only show section if the tag type exists in availableTagTypes
            if dataController.availableTagTypes.contains(type) {
                // Header for each tag type
                views.append(AnyView(dataController.tagHeaderView(for: type)))
                // Show items if expanded
                if dataController.shouldShowTags(for: type) {
                    views.append(contentsOf: tagFilterList(for: groupedTags[type, default: []]))
                }
            }
            return views
        }
    }
    private func tagFilterList(for filters: [Filter]) -> [AnyView] {
        filters.map { filter in
            AnyView(
                NavigationLink(value: filter) {
                    Text(LocalizedStringKey(filter.name))
                        .fontWeight(.light)
                        .badge("\(dataController.countTagPlates(for: filter.name))")
                        .accessibilityLabel(filter.name)
                        .accessibilityHint("\(dataController.countTagPlates(for: filter.name)) plates")
                }
            )
        }
    }
}

#Preview {
    SideBarView()
        .environmentObject(DataController.preview)
}

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
            Label(label, systemImage: systemImage)
                .badge("\(plateCount)")
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityHint(accessibilityHint)
    }
}

@ViewBuilder
private func expandableFilterSection(
    label: String,
    systemImage: String,
    isExpanded: Binding<Bool>,
    items: [some View]
) -> some View {
    Button {
        withAnimation {
            isExpanded.wrappedValue.toggle()
        }
    } label: {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
            Text(label)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded.wrappedValue ? 180 : 0))
                .foregroundColor(.secondary)
                .font(.footnote)
                .animation(.easeInOut(duration: 0.3), value: isExpanded.wrappedValue)
        }
    }
    if isExpanded.wrappedValue {
        ForEach(items.indices, id: \.self) { index in
            items[index]
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

struct QualityFiltersSection: View {
    let qualityFilters: [Filter]
    let countQualityPlates: (Int) -> Int
    var body: some View {
        Section("Quality filters") {
            ForEach(qualityFilters) { filter in
                NavigationLink(value: filter) {
                    qualityFilterRow(filter: filter)
                }
            }
            qualitySummaryText(
                goodCount: countQualityPlates(2),
                averageCount: countQualityPlates(1),
                badCount: countQualityPlates(0)
            )
        }
    }

    @ViewBuilder
    private func qualityFilterRow(filter: Filter) -> some View {
        HStack {
            Image(systemName: filter.icon)
                .foregroundColor(
                    filter.quality == 0 ? .red :
                    filter.quality == 1 ? .yellow : .green
                )
            Text(LocalizedStringKey(filter.name))
                .badge("\(countQualityPlates(filter.quality))")
        }
        .accessibilityElement()
        .accessibilityLabel(filter.name)
        .accessibilityHint("\(countQualityPlates(filter.quality)) plates")
    }

    @ViewBuilder
    private func qualitySummaryText(goodCount: Int, averageCount: Int, badCount: Int) -> some View {
        if goodCount > badCount && goodCount > averageCount {
            Text("You're doing great! Keep up with the healthy choices!")
                .foregroundColor(.green)
                .italic()
        } else if badCount > goodCount && badCount > averageCount {
            Text("You may want to focus on eating healthier.")
                .foregroundColor(.red)
                .italic()
        } else {
            Text("You're balancing your choices well!")
                .foregroundColor(.orange)
                .italic()
        }
    }
}

struct SideBarViewToolBar: View {
    @State private var showAwards = false
    var body: some View {
        Button {
            showAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showAwards, content: AwardsView.init)
    }
}
