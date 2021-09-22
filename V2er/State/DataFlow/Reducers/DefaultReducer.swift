//
//  Defaultreducer.swift
//  V2er
//
//  Created by ghui on 2021/9/22.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func defaultReducer(_ state: GlobalState, _ action: Action) -> (GlobalState, Action?) {
    var state = state
    var followingAction: Action?
    switch action {
        case let action as TabbarClickAction:
            state.lastSelectedTab = state.selectedTab
            state.selectedTab = action.selectedTab
            if state.lastSelectedTab == state.selectedTab {
                hapticFeedback(.light)
                state.scrollTop = state.selectedTab
            }
        default:
            break
    }
    return (state, action)
}
