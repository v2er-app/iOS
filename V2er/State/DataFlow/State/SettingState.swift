//
//  SettingState.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI
import Security

struct SettingState: FluxState {
    static let imgurClientIdKey = "imgurClientId"
    static let useBuiltinBrowserKey = "useBuiltinBrowser"
    static let v2exAccessTokenKey = "v2exAccessToken"
    static let showDataSourceIndicatorKey = "showDataSourceIndicator"
    static let v2exTokenEnabledKey = "v2exAccessTokenEnabled"

    var appearance: AppearanceMode = .system
    var autoCheckin: Bool = false
    var imgurClientId: String = ""
    var useBuiltinBrowser: Bool = false
    var v2exAccessToken: String = ""
    var v2exTokenEnabled: Bool = true
    var showDataSourceIndicator: Bool = false

    // Checkin state
    var isCheckingIn: Bool = false
    var lastCheckinDate: Date? = nil
    var checkinDays: Int = 0
    var checkinError: String? = nil

    init() {
        // Load saved preference
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode"),
           let mode = AppearanceMode(rawValue: savedMode) {
            self.appearance = mode
        }
        // Load auto-checkin preference
        self.autoCheckin = UserDefaults.standard.bool(forKey: "autoCheckin")
        // Load last checkin date
        if let lastCheckin = UserDefaults.standard.object(forKey: "lastCheckinDate") as? Date {
            self.lastCheckinDate = lastCheckin
        }
        // Load checkin days
        self.checkinDays = UserDefaults.standard.integer(forKey: "checkinDays")
        // Load Imgur client ID
        self.imgurClientId = UserDefaults.standard.string(forKey: Self.imgurClientIdKey) ?? ""
        // Load builtin browser preference
        self.useBuiltinBrowser = UserDefaults.standard.bool(forKey: Self.useBuiltinBrowserKey)
        // Load data source indicator preference
        self.showDataSourceIndicator = UserDefaults.standard.bool(forKey: Self.showDataSourceIndicatorKey)
        // Load V2EX access token enabled preference (defaults to true)
        if UserDefaults.standard.object(forKey: Self.v2exTokenEnabledKey) != nil {
            self.v2exTokenEnabled = UserDefaults.standard.bool(forKey: Self.v2exTokenEnabledKey)
        }
        // Load V2EX access token from Keychain (raw, for state display)
        self.v2exAccessToken = Self.getRawV2exAccessToken() ?? ""
    }

    static func saveImgurClientId(_ clientId: String) {
        UserDefaults.standard.set(clientId, forKey: imgurClientIdKey)
    }

    static func getImgurClientId() -> String? {
        let clientId = UserDefaults.standard.string(forKey: imgurClientIdKey)
        return (clientId?.isEmpty == false) ? clientId : nil
    }

    // MARK: - Per-user Keychain methods

    static func saveV2exAccessToken(_ token: String, forUser username: String) {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        let keychainKey = "\(v2exAccessTokenKey).\(username)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecAttrService as String: "v2er.app"
        ]
        SecItemDelete(query as CFDictionary)
        if trimmed.isEmpty { return }
        let data = Data(trimmed.utf8)
        var addQuery = query
        addQuery[kSecValueData as String] = data
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    static func getRawV2exAccessToken(forUser username: String) -> String? {
        let keychainKey = "\(v2exAccessTokenKey).\(username)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecAttrService as String: "v2er.app",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else {
            return nil
        }
        return token
    }

    static func deleteV2exAccessToken(forUser username: String) {
        let keychainKey = "\(v2exAccessTokenKey).\(username)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecAttrService as String: "v2er.app"
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Delegates to per-user save using the active account.
    static func saveV2exAccessToken(_ token: String) {
        guard let username = AccountManager.shared.activeUsername else {
            log("saveV2exAccessToken skipped: no active username")
            return
        }
        saveV2exAccessToken(token, forUser: username)
    }

    /// Returns the token only when it exists AND is enabled.
    static func getV2exAccessToken() -> String? {
        guard UserDefaults.standard.object(forKey: v2exTokenEnabledKey) == nil
                || UserDefaults.standard.bool(forKey: v2exTokenEnabledKey) else {
            return nil
        }
        return getRawV2exAccessToken()
    }

    /// Returns the stored token for the active user (for UI display).
    static func getRawV2exAccessToken() -> String? {
        guard let username = AccountManager.shared.activeUsername else { return nil }
        return getRawV2exAccessToken(forUser: username)
    }

    /// Migrates the legacy fixed-key token to a per-user key.
    static func migrateLegacyToken(toUser username: String) {
        let legacyQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: v2exAccessTokenKey,
            kSecAttrService as String: "v2er.app",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(legacyQuery as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else { return }
        // Save to per-user key
        saveV2exAccessToken(token, forUser: username)
        // Only delete legacy key if per-user save succeeded
        guard getRawV2exAccessToken(forUser: username) != nil else { return }
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: v2exAccessTokenKey,
            kSecAttrService as String: "v2er.app"
        ]
        SecItemDelete(deleteQuery as CFDictionary)
    }

    /// Check if we should attempt auto-checkin today
    /// Uses 8:00 AM as the reset time instead of midnight
    var shouldAutoCheckinToday: Bool {
        guard autoCheckin else { return false }
        guard let lastDate = lastCheckinDate else { return true }
        return !Self.isSameCheckinDay(lastDate, Date())
    }

    /// Check if two dates are in the same "checkin day" (resets at 8:00 AM)
    private static func isSameCheckinDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let resetHour = 8 // 8:00 AM

        // Calculate the "checkin day" for each date
        // If current hour < 8, it belongs to the previous calendar day's checkin period
        func checkinDay(for date: Date) -> DateComponents {
            let hour = calendar.component(.hour, from: date)
            if hour < resetHour {
                // Before 8 AM, belongs to previous day's checkin period
                let previousDay = calendar.date(byAdding: .day, value: -1, to: date)!
                return calendar.dateComponents([.year, .month, .day], from: previousDay)
            } else {
                // 8 AM or later, belongs to current day's checkin period
                return calendar.dateComponents([.year, .month, .day], from: date)
            }
        }

        let day1 = checkinDay(for: date1)
        let day2 = checkinDay(for: date2)

        return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day
    }
}

enum AppearanceMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        case .system:
            return "跟随系统"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

// Temporary: Define actions here until SettingActions.swift is properly added to project
struct SettingActions {
    private static let R: Reducer = .setting

    /// Error message constant for not-logged-in state
    static let notLoggedInError = "未登录"

    struct ChangeAppearanceAction: Action {
        var target: Reducer = R
        let appearance: AppearanceMode
    }

    struct ToggleAutoCheckinAction: Action {
        var target: Reducer = R
        let enabled: Bool
    }

    struct ToggleBuiltinBrowserAction: Action {
        var target: Reducer = R
        let enabled: Bool
    }

    struct ToggleDataSourceIndicatorAction: Action {
        var target: Reducer = R
        let enabled: Bool
    }

    struct ToggleV2exTokenEnabledAction: Action {
        var target: Reducer = R
        let enabled: Bool
    }

    struct StartAutoCheckinAction: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            // Only checkin if user is logged in
            guard AccountState.hasSignIn() else {
                dispatch(CheckinFailedAction(error: SettingActions.notLoggedInError))
                return
            }

            // Fetch daily mission info
            let dailyResult: APIResult<DailyInfo> = await APIService.shared.htmlGet(endpoint: .dailyMission)
            switch dailyResult {
            case .success(let dailyInfo):
                guard let info = dailyInfo else {
                    dispatch(CheckinFailedAction(error: "获取签到信息失败"))
                    return
                }

                // Already checked in today
                if info.hadCheckedIn {
                    let days = Int(info.checkedInDays) ?? 0
                    dispatch(CheckinSuccessAction(alreadyCheckedIn: true, days: days))
                    return
                }

                // Perform checkin with once token
                guard !info.once.isEmpty else {
                    dispatch(CheckinFailedAction(error: "签到令牌无效"))
                    return
                }

                let checkinResult: APIResult<DailyInfo> = await APIService.shared.htmlGet(
                    endpoint: .checkin,
                    ["once": info.once]
                )
                switch checkinResult {
                case .success(let result):
                    let days = Int(result?.checkedInDays ?? "0") ?? 0
                    dispatch(CheckinSuccessAction(alreadyCheckedIn: false, days: days))
                case .failure:
                    dispatch(CheckinFailedAction(error: "签到请求失败"))
                }

            case .failure:
                dispatch(CheckinFailedAction(error: "网络请求失败"))
            }
        }
    }

    struct CheckinSuccessAction: Action {
        var target: Reducer = R
        let alreadyCheckedIn: Bool
        let days: Int
    }

    struct CheckinFailedAction: Action {
        var target: Reducer = R
        let error: String
    }
}