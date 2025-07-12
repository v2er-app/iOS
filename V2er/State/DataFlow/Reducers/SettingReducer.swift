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
        followingAction = nil
    default:
        break
    }
    
    return (state, followingAction)
}





