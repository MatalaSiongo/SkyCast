//
//  NotificationManager.swift
//  SkyCast
//
//  Created by Matala on 2026-09-05.
import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {

    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private let dailyReminderIdentifier = "skycast.daily.weather.reminder"

    private init() {}

    // MARK: - Refresh Permission Status

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            await refreshAuthorizationStatus()

            return granted
        } catch {
            await refreshAuthorizationStatus()
            return false
        }
    }

    // MARK: - Schedule Daily Reminder

    func scheduleDailyReminder(
        hour: Int,
        minute: Int
    ) async throws {

        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .authorized ||
                settings.authorizationStatus == .provisional else {
            throw NotificationManagerError.permissionNotGranted
        }

        center.removePendingNotificationRequests(
            withIdentifiers: [
                dailyReminderIdentifier
            ]
        )

        let content = UNMutableNotificationContent()

        content.title = "SkyCast Weather"
        content.body = "Check today’s weather before you head out."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    // MARK: - Cancel Daily Reminder

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(
            withIdentifiers: [
                dailyReminderIdentifier
            ]
        )
    }

    // MARK: - Test Notification

    func scheduleTestNotification() async throws {

        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .authorized ||
                settings.authorizationStatus == .provisional else {
            throw NotificationManagerError.permissionNotGranted
        }

        let content = UNMutableNotificationContent()

        content.title = "SkyCast Test"
        content.body = "Notifications are working correctly."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "skycast.test.notification",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    // MARK: - Pending Reminder Check

    func hasScheduledDailyReminder() async -> Bool {

        let requests =
            await center.pendingNotificationRequests()

        return requests.contains {
            $0.identifier ==
                dailyReminderIdentifier
        }
    }
}

// MARK: - Errors

enum NotificationManagerError: LocalizedError {

    case permissionNotGranted

    var errorDescription: String? {

        switch self {

        case .permissionNotGranted:
            return "Notification permission has not been granted."
        }
    }
}
