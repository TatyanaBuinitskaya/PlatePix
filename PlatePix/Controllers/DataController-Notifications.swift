//
//  DataController-Notifications.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 10.02.2025.
//

import Foundation
import UserNotifications

extension DataController {
    /// Adds a reminder notification for the user.
       /// - Returns: `true` if the reminder was successfully scheduled, otherwise `false`.
    func addReminder() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                // If the user has not granted permission, request it first.
                let success = try await requestNotifications()

                if success {
                    try await placeReminders()  // Schedule a reminder if permission is granted.
                } else {
                    return false
                }

            case .authorized:
                // If permission is already granted, schedule the reminder.
                try await placeReminders()

            default:
                // If notifications are denied or restricted, do nothing.
                return false
            }

            return true
        } catch {
            // Return false if any error occurs.
            return false
        }
    }

    /// Removes all pending reminder notifications.
    func removeReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }

    /// Requests notification permissions from the user.
       /// - Returns: `true` if permission is granted, otherwise `false`.
    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }
    
    /// Schedules a reminder notification for the user.
        private func placeReminders() async throws {
            let reminders = [
                        (title: "🍽️ Time to log your meal!", subtitle: "Snap a photo of your plate to track your progress."),
                        (title: "📸 Don't forget your food photo!", subtitle: "A quick photo of your meal helps you stay on track."),
                        (title: "⏳ Did you eat already?", subtitle: "Capture your meal before you forget!"),
                        (title: "💧 Stay Hydrated!", subtitle: "Drinking water helps with weight loss and digestion."),
                        (title: "🚰 Time for a sip!", subtitle: "A glass of water before your meal can help control hunger."),
                        (title: "🎯 Keep going!", subtitle: "Small steps lead to big results. Stay consistent!"),
                        (title: "🏆 You're making progress!", subtitle: "Every plate you track brings you closer to your goal."),
                        (title: "💪 Stay strong!", subtitle: "Your effort today will show tomorrow.")
                    ]

            // Select a random reminder from the list
            let randomReminder = reminders.randomElement()!

            // Configure the notification content
            let content = UNMutableNotificationContent()
            content.sound = .default
                content.title = randomReminder.title
                content.subtitle = randomReminder.subtitle

            // Scheduling the notification to trigger after 5 seconds (for testing)
            //        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            //        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            // fot testing
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            // Create the notification request with a unique identifier
            let request = UNNotificationRequest(identifier: "plateReminder", content: content, trigger: trigger)
            // Add the notification request to the system
            return try await UNUserNotificationCenter.current().add(request)
    }
}
