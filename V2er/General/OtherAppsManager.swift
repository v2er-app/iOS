//
//  OtherAppsManager.swift
//  V2er
//
//  Created on 2026/2/3.
//  Copyright © 2026 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

/// Manages the cross-promotion apps section and red dot badge state
class OtherAppsManager: ObservableObject {
    static let shared = OtherAppsManager()

    // MARK: - Keys
    private enum Keys {
        static let showOtherAppsBadge = "showOtherAppsBadge"
        static let firstLaunchDate = "v2er_firstLaunchDate"
        static let appLaunchCount = "v2er_appLaunchCount"
    }

    // MARK: - Published Properties
    @AppStorage(Keys.showOtherAppsBadge) var showOtherAppsBadge: Bool = false

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Badge Logic

    /// Refresh whether to show the other apps badge
    /// Conditions: installed 3+ days, launched 10+ times, never dismissed
    func refreshBadge() {
        // Already dismissed by user
        guard !userDefaults.bool(forKey: Keys.showOtherAppsBadge + "_dismissed") else {
            showOtherAppsBadge = false
            return
        }

        // Check if installed for at least 3 days
        guard daysSinceInstall() >= 3 else {
            return
        }

        // Check if launched at least 10 times
        guard getLaunchCount() >= 10 else {
            return
        }

        showOtherAppsBadge = true
    }

    /// Dismiss the badge (user tapped on the section)
    func dismissBadge() {
        showOtherAppsBadge = false
        userDefaults.set(true, forKey: Keys.showOtherAppsBadge + "_dismissed")
    }

    /// Record app launch for badge trigger logic
    func recordLaunch() {
        // Record first launch date if not set
        if userDefaults.object(forKey: Keys.firstLaunchDate) == nil {
            userDefaults.set(Date(), forKey: Keys.firstLaunchDate)
        }

        // Increment launch count
        let count = getLaunchCount()
        userDefaults.set(count + 1, forKey: Keys.appLaunchCount)
    }

    // MARK: - Private Helpers

    private func daysSinceInstall() -> Int {
        guard let firstLaunch = userDefaults.object(forKey: Keys.firstLaunchDate) as? Date else {
            return 0
        }
        let days = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return days
    }

    private func getLaunchCount() -> Int {
        return userDefaults.integer(forKey: Keys.appLaunchCount)
    }
}

// MARK: - App Model

struct OtherApp: Identifiable {
    let id: String
    let name: String
    let description: String
    let appStoreId: String
    let iconName: String

    var appStoreUrl: URL? {
        URL(string: "https://apps.apple.com/app/apple-store/id\(appStoreId)?pt=118108268&ct=V2er&mt=8")
    }
}

// MARK: - Available Apps

extension OtherAppsManager {
    /// List of apps to promote
    static let otherApps: [OtherApp] = [
        OtherApp(
            id: "ulpb",
            name: "试试双拼",
            description: "双拼打字练习，提升输入效率",
            appStoreId: "1613019131",
            iconName: "ulpb_icon"
        ),
        OtherApp(
            id: "daystill",
            name: "DaysTill",
            description: "跟踪事件和特殊日子",
            appStoreId: "6474996230",
            iconName: "daystill_icon"
        ),
        OtherApp(
            id: "shione",
            name: "诗一",
            description: "每天一首诗，品味古典之美",
            appStoreId: "6758235112",
            iconName: "shione_icon"
        ),
        OtherApp(
            id: "flarekit",
            name: "FlareKit",
            description: "Cloudflare 数据统计分析",
            appStoreId: "6757950534",
            iconName: "flarekit_icon"
        )
    ]
}
