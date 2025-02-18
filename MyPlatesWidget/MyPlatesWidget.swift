//
//  MyPlatesWidget.swift
//  MyPlatesWidget
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
        SimpleEntry(date: Date(), text: "Stay motivated!", color: .watermelonPink) // Default placeholder text
    }

    /// Returns a snapshot of the widget's current state.
    /// Used for previews and when the widget is displayed for the first time.
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Load today's motivation text
        let motivationText = loadTodaysMotivation()
        
        // Create a snapshot entry using the loaded motivation
        let entry = SimpleEntry(date: Date(), text: motivationText, color: loadColor())
        completion(entry)
    }

    /// Supplies the timeline of entries for the widget.
    /// It refreshes once a day with a new motivational message.
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Load today's motivation text
        let motivationText = loadTodaysMotivation()

        var entries: [SimpleEntry] = []
        let currentDate = Date()

        // Create an entry for the current day
        let entry = SimpleEntry(date: currentDate, text: motivationText, color: loadColor())
        entries.append(entry)

        // Schedule the next update for tomorrow at midnight
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!

        // Create the timeline with a policy to update daily
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    /// Loads today's motivational message, ensuring it's refreshed daily.
    /// This function uses shared `UserDefaults` to store the last shown message.
    func loadTodaysMotivation() -> String {
        // Access the shared UserDefaults using App Group identifier
        if let sharedDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates") {
            let lastDate = sharedDefaults.object(forKey: "lastMotivationDate") as? Date ?? Date.distantPast
            let calendar = Calendar.current
            
            // Check if the stored date is today.
            if calendar.isDateInToday(lastDate),
               let savedID = sharedDefaults.value(forKey: "lastMotivationID") as? Int {
                // Same day: Load saved motivation
                if let savedMotivation = Motivations.motivations.first(where: { $0.id == savedID }) {
                    return savedMotivation.localizedText
                }
            }
            
            // New day: Pick a new random motivation
            let newMotivation = pickNewRandomMotivation()
            
            // Save the new date and motivation ID and text
            sharedDefaults.set(Date(), forKey: "lastMotivationDate")
            sharedDefaults.set(newMotivation.id, forKey: "lastMotivationID")
            sharedDefaults.set(newMotivation.localizedText, forKey: "lastMotivationText")
            sharedDefaults.synchronize()
            
            return newMotivation.localizedText
            
        } else {
            print("Failed to access shared UserDefaults")
            return "Stay motivated!"
        }
    }

    /// Picks a new random motivation ensuring it's different from the last one.
    /// Prevents showing the same message consecutively.
    func pickNewRandomMotivation() -> Motivation {
        var newMotivation: Motivation
        
        // Repeat until a different motivation is chosen
        repeat {
            newMotivation = Motivations.motivations.randomElement()!
        } while newMotivation.id == UserDefaults.standard.integer(forKey: "lastMotivationID")
        
        return newMotivation
    }
    
    private func loadColor() -> AppColor {
           if let groupDefaults = UserDefaults(suiteName: "group.com.TatianaBuinitskaia.MyPlates"),
              let rawValue = groupDefaults.string(forKey: "selectedColor"),
              let color = AppColor(rawValue: rawValue) {
               return color
           }
           return .watermelonPink
       }
}

///  Model for the widget's data.
struct SimpleEntry: TimelineEntry {
    let date: Date // The date of the entry, required by TimelineEntry protocol
    let text: String // The motivational text to display
    let color: AppColor
}

/// MyPlatesWidgetEntryView is responsible for rendering the widget UI.
struct MyPlatesWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily // // Detects the widget size and type
    var entry: Provider.Entry // The data for the widget entry
    
    var body: some View {
        switch widgetFamily {
            
        case .systemMedium: // Medium widget size
            if #available(iOS 17.0, *) {
                Text(entry.text)
                    .font(.title3)
                    .minimumScaleFactor(0.6)
                    .foregroundColor(entry.color.color)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                 //   .containerBackground(colorManager.selectedColor.color, for: .widget) // iOS 17+ styling
                   
            } else {
                Text(entry.text)
                    .font(.title3)
                    .minimumScaleFactor(0.6)
                    .foregroundColor(entry.color.color)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
//                    .padding()
//                    .edgesIgnoringSafeArea(.all)
//                    .background(colorManager.selectedColor.color)
               
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

/// MyPlatesWidget is the main widget configuration.
struct MyPlatesWidget: Widget {
    let kind: String = "MyPlatesWidget" // Unique identifier for the widget

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                    MyPlatesWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget) // iOS 17+ background

            } else {
                MyPlatesWidgetEntryView(entry: entry)
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

/// MyPlatesWidget_Previews provides previews for the widget in Xcode.
struct MyPlatesWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        // Preview for medium widget
        MyPlatesWidgetEntryView(entry: SimpleEntry(date: Date(), text: Motivations.motivations[0].localizedText, color: .watermelonPink))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")
        
        // Preview for lock screen widget
        MyPlatesWidgetEntryView(entry: SimpleEntry(date: Date(), text: Motivations.motivations[0].localizedText, color: .watermelonPink))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }
}
