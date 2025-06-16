//
//  PlatePixWidget.swift
//  PlatePixWidget
//
//  Created by Tatyana Buinitskaya on 13.02.2025.
//

import Foundation
import WidgetKit
import SwiftUI

/// Provider is responsible for supplying the timeline entries to the widget.
struct Provider: TimelineProvider {
    /// Returns a placeholder view used in widget configuration and previews.
    /// This is shown while the widget data is being loaded.
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "Stay motivated!", color: .lavenderRaf) // Default placeholder text
    }

    /// Returns a snapshot of the widget's current state.
    /// Used for previews and when the widget is displayed for the first time.
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        // Load today's motivation text
        let index = loadTodaysMotivationIndex()
        let motivation = Motivations.motivations[index]
        // Create a snapshot entry using the loaded motivation
        let entry = SimpleEntry(date: Date(), text: motivation.localizedText, color: loadColor())
        completion(entry)
    }

    /// Supplies the timeline of entries for the widget.
    /// It refreshes once a day with a new motivational message.
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Load today's motivation text
        let index = loadTodaysMotivationIndex()
        let motivation = Motivations.motivations[index]

        var entries: [SimpleEntry] = []
        let currentDate = Date()

        // Create an entry for the current day
        let entry = SimpleEntry(date: currentDate, text: motivation.localizedText, color: loadColor())
        entries.append(entry)

        // Schedule the next update for tomorrow at midnight
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!

        // Create the timeline with a policy to update daily
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    func loadTodaysMotivationIndex() -> Int {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix") {
            let lastDate = sharedDefaults.object(forKey: "lastMotivationDate") as? Date ?? Date.distantPast
            let calendar = Calendar.current

            if calendar.isDateInToday(lastDate) {
                if sharedDefaults.object(forKey: "lastMotivationIndex") != nil {
                    return sharedDefaults.integer(forKey: "lastMotivationIndex")
                }
            }

            let newMotivationIndex = pickNewRandomMotivationIndex()
            saveMotivationIndexToDefaults(newMotivationIndex)
            return newMotivationIndex
        } else {
            print("Failed to access shared UserDefaults")
            return 0
        }
    }

    /// Saves the generated motivation index  to `UserDefaults`
    private func saveMotivationIndexToDefaults(_ index: Int) {
        let defaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix")!
        defaults.set(index, forKey: "lastMotivationIndex")
        defaults.set(Date(), forKey: "lastMotivationDate")
        defaults.synchronize()
    }

    /// Picks a new random motivation  index ensuring it's different from the last one.
    /// Prevents showing the same message consecutively.
    func pickNewRandomMotivationIndex() -> Int {
        var newMotivationIndex: Int

        // Repeat until a different motivation is chosen
        repeat {
            newMotivationIndex = Motivations.motivations.randomElement()!.id
        } while newMotivationIndex == UserDefaults.standard.integer(forKey: "lastMotivationIndex")

        return newMotivationIndex
    }

    private func loadColor() -> AppColor {
        if let groupDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.PlatePix"),
           let rawValue = groupDefaults.string(forKey: "selectedColor"),
           let color = AppColor(rawValue: rawValue) {
            return color
        }
        return .lavenderRaf
    }
}

///  Model for the widget's data.
struct SimpleEntry: TimelineEntry {
    let date: Date // The date of the entry, required by TimelineEntry protocol
    let text: String // The motivational text to display
    let color: AppColor
}

/// PlatePixWidgetEntryView is responsible for rendering the widget UI.
struct PlatePixWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily // // Detects the widget size and type
    var entry: Provider.Entry // The data for the widget entry

    var body: some View {
        switch widgetFamily {

        case .systemMedium: // Medium widget size
            if #available(iOS 17.0, *) {
                VStack {
                    Text(entry.text)
                        .font(.title3)
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text(entry.text)
                    .font(.title3)
                    .minimumScaleFactor(0.6)
                    .foregroundColor(entry.color.color)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
            }
        case .accessoryRectangular: // Lock screen widget
            Text(entry.text)
                .font(.body)
                .minimumScaleFactor(0.1)
        default:
            Text("Not implemented") // Default case for unsupported sizes
        }
    }
}

/// PlatePixWidget is the main widget configuration.
struct PlatePixWidget: Widget {
    let kind: String = "PlatePixWidget" // Unique identifier for the widget

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PlatePixWidgetEntryView(entry: entry)
                    .containerBackground(entry.color.color, for: .widget) // iOS 17+ styling
            } else {
                PlatePixWidgetEntryView(entry: entry)
                    .padding()
                    .edgesIgnoringSafeArea(.all)
                    .background()
            }
        }
        .configurationDisplayName("Motivation of the Day") // Display name in widget gallery
        .description("Shows a new motivational message every day.") // Description in widget gallery
        .supportedFamilies([.systemMedium, .accessoryRectangular]) // Supported widget sizes
    }
}

/// PlatePixWidget_Previews provides previews for the widget in Xcode.
struct PlatePixWidget_Previews: PreviewProvider {

    static var previews: some View {
        // Preview for medium widget
        PlatePixWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            text: Motivations.motivations[0].localizedText,
            color: .lavenderRaf
        ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")

        // Preview for lock screen widget
        PlatePixWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            text: Motivations.motivations[0].localizedText,
            color: .lavenderRaf
        ))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }
}
