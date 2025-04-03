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

    private func placeReminders() async throws {
        // Pick a new random reminder index
        let newIndex = pickNewRandomReminderIndex()
        UserDefaults.standard.set(newIndex, forKey: "lastReminderIndex")

        let reminderText = Reminders.reminders[newIndex].localizedText

        // Configure the notification content
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.body = reminderText

        // Scheduling the notification to trigger after 5 seconds (for testing)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // fot testing
        //    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create the notification request with a unique identifier
        let request = UNNotificationRequest(identifier: "plateReminder", content: content, trigger: trigger)
        // Add the notification request to the system
        return try await UNUserNotificationCenter.current().add(request)
    }

    private func pickNewRandomReminderIndex() -> Int {
        var newIndex: Int

        // Repeat until a different motivation is chosen
        repeat {
            newIndex = Reminders.reminders.randomElement()!.id
        } while newIndex == UserDefaults.standard.integer(forKey: "lastReminderIndex")

        // Save the new index to UserDefaults
        UserDefaults.standard.set(newIndex, forKey: "lastReminderIndex")

        return newIndex
    }
}
