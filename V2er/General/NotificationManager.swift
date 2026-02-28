//
//  NotificationManager.swift
//  V2er
//
//  Manages daily hot topic push notifications.
//  Uses UNCalendarNotificationTrigger for reliable timing
//  and BGAppRefreshTask to keep notification content fresh.
//

import Foundation
import UserNotifications
#if os(iOS)
import BackgroundTasks
#endif

final class NotificationManager {
    static let shared = NotificationManager()
    static let bgTaskIdentifier = "v2er.app.dailyHotRefresh"
    private static let notificationCategoryId = "dailyHotTopics"
    private static let pendingNotificationId = "dailyHotTopicNotification"

    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                log("Notification permission error: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAllowed: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                isAllowed = true
            case .denied, .notDetermined:
                isAllowed = false
            @unknown default:
                isAllowed = false
            }
            DispatchQueue.main.async {
                completion(isAllowed)
            }
        }
    }

    // MARK: - Schedule Notification

    /// Schedules a local notification at the user's preferred time with hot topic content.
    func scheduleHotTopicNotification() {
        let settings = Store.shared.appState.settingState
        guard settings.dailyHotPush else { return }

        let hotItems = Store.shared.appState.exploreState.exploreInfo.dailyHotInfo
        if hotItems.isEmpty {
            Task {
                let result: APIResult<ExploreInfo> = await APIService.shared.htmlGet(endpoint: .explore)
                if case .success(let info) = result, let info = info {
                    await MainActor.run {
                        self.createNotification(with: info.dailyHotInfo)
                    }
                }
            }
        } else {
            createNotification(with: hotItems)
        }
    }

    private func createNotification(with hotItems: [ExploreInfo.DailyHotItem]) {
        guard !hotItems.isEmpty else { return }

        let settings = Store.shared.appState.settingState
        let hour = settings.dailyHotPushHour
        let minute = settings.dailyHotPushMinute

        let content = UNMutableNotificationContent()
        content.title = "今日热议"
        content.categoryIdentifier = Self.notificationCategoryId

        let topItems = Array(hotItems.prefix(3))
        let body = topItems.enumerated().map { index, item in
            "\(index + 1). \(item.title)"
        }.joined(separator: "\n")
        content.body = body
        content.sound = .default

        if let firstItem = topItems.first {
            content.userInfo = ["topicId": firstItem.id]
        }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Self.pendingNotificationId,
            content: content,
            trigger: trigger
        )

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.pendingNotificationId])
        center.add(request) { error in
            if let error = error {
                log("Failed to schedule notification: \(error)")
            } else {
                log("Scheduled daily hot notification for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    // MARK: - Cancel

    func cancelPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.pendingNotificationId])
        center.removeDeliveredNotifications(withIdentifiers: [Self.pendingNotificationId])
        log("Cancelled hot topic notifications")
    }

    // MARK: - Background Task

    #if os(iOS)
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }

    func scheduleBackgroundRefresh() {
        let settings = Store.shared.appState.settingState
        guard settings.dailyHotPush else { return }

        // Cancel existing request before submitting new one
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.bgTaskIdentifier)

        let request = BGAppRefreshTaskRequest(identifier: Self.bgTaskIdentifier)

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = settings.dailyHotPushHour
        components.minute = settings.dailyHotPushMinute

        if let nextDate = calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        ) {
            let refreshDate = calendar.date(byAdding: .minute, value: -30, to: nextDate) ?? nextDate
            request.earliestBeginDate = refreshDate
        } else {
            request.earliestBeginDate = Date(timeIntervalSinceNow: 8 * 3600)
        }

        do {
            try BGTaskScheduler.shared.submit(request)
            log("Scheduled background refresh")
        } catch {
            log("Failed to schedule background refresh: \(error)")
        }
    }

    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        scheduleBackgroundRefresh()

        let fetchTask = Task {
            var didScheduleNotification = false
            let result: APIResult<ExploreInfo> = await APIService.shared.htmlGet(endpoint: .explore)
            if case .success(let info) = result, let info = info {
                await MainActor.run {
                    self.createNotification(with: info.dailyHotInfo)
                }
                didScheduleNotification = true
            }
            task.setTaskCompleted(success: didScheduleNotification)
        }

        task.expirationHandler = {
            fetchTask.cancel()
            task.setTaskCompleted(success: false)
        }
    }
    #else
    func registerBackgroundTask() {}
    func scheduleBackgroundRefresh() {}
    #endif
}
