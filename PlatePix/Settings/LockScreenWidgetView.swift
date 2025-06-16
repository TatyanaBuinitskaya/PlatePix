//
//  LockScreenWidgetView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 19.02.2025.
//

import SwiftUI

/// A view that provides instructions for adding a widget to the Lock Screen.
struct LockScreenWidgetView: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack {
                Text("Follow instructions to reach")
                Text("your motivations even on your")
            }
            .font(.headline)
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(10)

            Text("LOCK SCREEN")
                .font(.title.bold())
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
                .frame(alignment: .center)
            // Lock Screen Widget example section
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    // Display current date
                    let currentDate = getCurrentDate()
                    Text(currentDate)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    // Display current time in a large font
                    let currentTime = getCurrentTime()
                    Text(currentTime)
                        .font(.system(size: 90))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(0)
                    // Motivational message
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Reading motivations")
                            Text("regulary will help")
                            Text("you to reach your goal")
                        }
                        .font(.footnote)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: 350)
                .background(
                    LinearGradient(
                        colors: [Color("LavenderRaf"), Color("GirlsPink")],
                        startPoint: .bottom,
                        endPoint: .top)
                )
                .padding(.horizontal)
                Spacer()
            }

            // Instructions for Adding Widget
            VStack(alignment: .leading, spacing: 20) {
                Text("1. Touch and hold anywhere on your lock screen, tap Customize and choose Lock Screen.")
                // swiftlint:disable:next line_length
                Text("2. Tap and hold the widgets area, then find the PlatePix widget from the suggested list.")
                Text("3. Tap or drag to add widget, then close the window and press Done.")
            }
            .font(.callout)
            .fontWeight(.regular)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            Spacer()
            Spacer()
        }
    }

    /// Returns the current date formatted as "Day, Month Date" (e.g., "Monday, February 19").
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
        let dateString = formatter.string(from: Date())
        return dateString
    }

    /// Returns the current time in a short format (e.g., "3:45 PM").
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: Date())
        return timeString
    }
}

#Preview("English") {
    LockScreenWidgetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    LockScreenWidgetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
