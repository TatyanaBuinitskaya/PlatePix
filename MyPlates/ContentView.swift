//
//  ContentView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @State private var isNewPlateCreated = false
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
          NavigationStack {
              ZStack {
                  VStack {
                      motivation
                      plateGrid
                  }
                  .padding()
                  floatingControls
              }
              .navigationTitle(LocalizedStringKey(dataController.dynamicTitle))
              .navigationBarTitleDisplayMode(.inline)
              .toolbar(content: ContentViewToolBar.init)
              .navigationDestination(for: Plate.self) { plate in
                  PlateView(plate: plate)
              }
              .navigationDestination(isPresented: $isNewPlateCreated) {
                  if let newPlate = dataController.selectedPlate {
                      PlateView(plate: newPlate)
                  }
              }
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
    private var motivation: some View {
        Text("You can become who you want")
            .font(.headline)
            .padding(.bottom, 8)
    }
    private var plateGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(dataController.platesForSelectedFilter()) { plate in
                    NavigationLink(value: plate) {
                        PlateBox(plate: plate)
                    }
                }
            }
            .searchable(
                text: $dataController.filterText,
                prompt: "Filter plates"
            )
        }
    }
    private var floatingControls: some View {
        VStack {
            Spacer()
            HStack {
                filterToggles
                Spacer()
                addPlateButton
            }
        }
        .padding()
    }
    private var filterToggles: some View {
        HStack {
            filterToggle(label: "time", isOn: $dataController.showMealTime)
            filterToggle(label: "quality", isOn: $dataController.showQuality)
            filterToggle(label: "notes", isOn: $dataController.showNotes)
            filterToggle(label: "tags", isOn: $dataController.showTags)
        }
        .padding(5)
        .background(Capsule().fill(Color.blue))
    }
    private func filterToggle(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
    }
    private var addPlateButton: some View {
        Button {
            dataController.newPlate()
            isNewPlateCreated = true
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

struct ContentViewToolBar: View {
    @State private var showPDFSheet = false
    @State private var isNavigatingToSettings = false
    var body: some View {
        Button {
            showPDFSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $showPDFSheet) {
            PDFSheetShareView()
        }
        Button {
            isNavigatingToSettings = true
        } label: {
            Image(systemName: "gear")
        }
        .navigationDestination(isPresented: $isNavigatingToSettings) {
            SettingsView()
        }
    }
}
