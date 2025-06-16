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
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            let granted = try? await center.requestAuthorization(options: [.alert, .sound])
            if granted == true {
                try? await scheduleReminder()
                return true
            } else {
                return false
            }

        case .authorized:
            let existing = await center.pendingNotificationRequests()
            let exists = existing.contains { $0.identifier == "dailyMealReminder" }

            if !exists {
                try? await scheduleReminder()
            }
            return true

        default:
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

    /// Schedules a daily notification to remind users to take a photo of their meal.
    /// Helps promote mindful eating by encouraging regular food tracking.
    ///
    /// - Throws: An error if scheduling the notification fails.
    private func placeReminder() async throws {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // remove any previous reminders

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.body = NSLocalizedString("Don't forget to take photos of your plates, it will help you eat mindfully!📸🍴", comment: "")

        // Schedule at user's selected time (daily)
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "dailyMealReminder",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Schedules a daily local notification reminding the user to take photos of their meals.
    /// The notification triggers at the user-specified `reminderTime`.
    private func scheduleReminder() async throws {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.body = NSLocalizedString("Don't forget to take photos of your plates, it will help you eat mindfully!📸🍴", comment: "")

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "dailyMealReminder",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    /// Updates the daily meal reminder notification.
    /// Removes any existing reminder and reschedules it if reminders are enabled.
    func updateReminder() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMealReminder"])

        if reminderEnabled {
            _ = await addReminder()
        }
    }
}
