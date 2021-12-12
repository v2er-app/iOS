//
//  MeReducer.swift
//  MeReducer
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func meStateReducer(_ state: MeState, _ action: Action) -> (MeState, Action?) {
    var state = state
    var followingAction: Action?

    switch action {
//        case let action as MeActions.ShowLoginPageAction:
//            guard !state.showLoginView else { break }
//            state.showLoginView = true
        default:
            break
    }
    return (state, followingAction)
}
