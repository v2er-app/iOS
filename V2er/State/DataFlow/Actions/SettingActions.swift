//
//  SettingActions.swift
//  V2er
//
//  Created by ghui on 2025/1/12.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import Foundation

private let R: Reducer = .setting

struct ChangeAppearanceAction: Action {
    var target: Reducer = R
    let appearance: AppearanceMode
}

func settingStateReducer(_ state: SettingState, _ action: Action?) -> (SettingState, Action?) {
    var state = state
    var followingAction = action
    
    switch action {
    case let action as ChangeAppearanceAction:
        state.appearance = action.appearance
        // Save to UserDefaults
        UserDefaults.standard.set(action.appearance.rawValue, forKey: "appearanceMode")
        followingAction = nil
    default:
        break
    }
    
    return (state, followingAction)
}