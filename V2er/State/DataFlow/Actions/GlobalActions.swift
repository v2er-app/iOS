//
//  GlobalActions.swift
//  V2er
//
//  Created by ghui on 2021/9/22.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

private let R: Reducer = .global

struct OnAppearChangeAction: Action {
    var target: Reducer
    var id: String
    var isAppear: Bool
}

struct InstanceDestoryAction: Action {
    var target: Reducer = R
    var id: String
}

protocol InstanceIdentifiable {
    var instanceId: String {
        get
    }
}

struct TabbarClickAction: Action {
    var target: Reducer = R

    let selectedTab: TabId
}

struct ShowToastAction: Action {
    var target: Reducer = R
    let title: String
    var icon: String = .empty
}


func globalStateReducer(_ state: GlobalState, _ action: Action?) -> (GlobalState, Action?) {
    var state = state
    var followingAction = action
    switch action {
        case let action as ShowToastAction:
            state.toast.title = action.title
            state.toast.icon = action.icon
            state.toast.isPresented = true
            break
        default:
            break
    }
    return (state, followingAction)
}
