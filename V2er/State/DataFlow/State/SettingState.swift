//
//  SettingState.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingState: FluxState {
    var appearance: AppearanceMode = .system
    var autoCheckin: Bool = false

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
    }

    /// Check if we should attempt auto-checkin today
    var shouldAutoCheckinToday: Bool {
        guard autoCheckin else { return false }
        guard let lastDate = lastCheckinDate else { return true }
        return !Calendar.current.isDateInToday(lastDate)
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

    struct ChangeAppearanceAction: Action {
        var target: Reducer = R
        let appearance: AppearanceMode
    }

    struct ToggleAutoCheckinAction: Action {
        var target: Reducer = R
        let enabled: Bool
    }

    struct StartAutoCheckinAction: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            // Only checkin if user is logged in
            guard AccountState.hasSignIn() else { return }

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