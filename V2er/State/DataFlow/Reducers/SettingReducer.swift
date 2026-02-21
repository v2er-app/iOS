//
//  SettingReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func settingStateReducer(_ state: SettingState, _ action: Action) -> (SettingState, Action?) {
    var state = state
    var followingAction: Action? = action

    switch action {
    case let action as SettingActions.ChangeAppearanceAction:
        state.appearance = action.appearance
        // Save to UserDefaults
        UserDefaults.standard.set(action.appearance.rawValue, forKey: "appearanceMode")
        UserDefaults.standard.synchronize()

        // Post notification for immediate UI update
        NotificationCenter.default.post(name: NSNotification.Name("AppearanceDidChange"), object: action.appearance)

        followingAction = nil

    case let action as SettingActions.ToggleAutoCheckinAction:
        state.autoCheckin = action.enabled
        UserDefaults.standard.set(action.enabled, forKey: "autoCheckin")
        followingAction = nil

    case let action as SettingActions.ToggleBuiltinBrowserAction:
        state.useBuiltinBrowser = action.enabled
        UserDefaults.standard.set(action.enabled, forKey: SettingState.useBuiltinBrowserKey)
        followingAction = nil

    case let action as SettingActions.ToggleDataSourceIndicatorAction:
        state.showDataSourceIndicator = action.enabled
        UserDefaults.standard.set(action.enabled, forKey: SettingState.showDataSourceIndicatorKey)
        followingAction = nil

    case let action as SettingActions.ToggleV2exTokenEnabledAction:
        state.v2exTokenEnabled = action.enabled
        UserDefaults.standard.set(action.enabled, forKey: SettingState.v2exTokenEnabledKey)
        followingAction = nil

    case _ as SettingActions.StartAutoCheckinAction:
        state.isCheckingIn = true
        state.checkinError = nil
        // followingAction remains as action to execute async

    case let action as SettingActions.CheckinSuccessAction:
        state.isCheckingIn = false
        state.checkinDays = action.days
        state.lastCheckinDate = Date()
        state.checkinError = nil
        // Save per-user checkin data
        UserDefaults.standard.set(Date(), forKey: SettingState.checkinDateKey)
        UserDefaults.standard.set(action.days, forKey: SettingState.checkinDaysKey)

        // Show toast notification
        if action.alreadyCheckedIn {
            Toast.show("今日已签到，连续 \(action.days) 天")
        } else {
            Toast.show("签到成功！连续 \(action.days) 天")
        }
        followingAction = nil

    case let action as SettingActions.CheckinFailedAction:
        state.isCheckingIn = false
        state.checkinError = action.error
        log("Checkin failed: \(action.error)")
        // Don't show toast for not-logged-in errors (silent fail for auto-checkin)
        if action.error != SettingActions.notLoggedInError {
            Toast.show("签到失败，请稍后再试")
        }
        followingAction = nil

    default:
        break
    }

    return (state, followingAction)
}





