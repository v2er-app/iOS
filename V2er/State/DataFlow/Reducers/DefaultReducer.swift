//
//  Defaultreducer.swift
//  V2er
//
//  Created by ghui on 2021/9/22.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import UIKit

func defaultReducer(_ state: AppState, _ action: Action) -> (AppState, Action?) {
    var state = state
    var globalState = state.globalState
    var followingAction: Action?
    switch action {
        case let action as TabbarClickAction:
            globalState.lastSelectedTab = globalState.selectedTab
            globalState.selectedTab = action.selectedTab
            if globalState.lastSelectedTab == globalState.selectedTab {
                hapticFeedback(.soft)
                globalState.scrollTopTab = globalState.selectedTab
                let tab = globalState.scrollTopTab
                if tab == .message {
                    state
                        .messageState
                        .updatableState
                        .scrollToTop += 1
                }
                // TODO: refactor
            }
        default:
            break
    }
    state.globalState = globalState
    return (state, action)
}
