//
//  FeedDetailReducer.swift
//  FeedDetailReducer
//
//  Created by ghui on 2021/9/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func feedDetailStateReducer(_ states: FeedDetailStates, _ action: Action) -> (FeedDetailStates, Action?) {
    guard let id = action.id else {
        fatalError("Action in FeedDetail couldn't be null")
        return (states, action)
    }
    var states = states
    var state = states[id]!
    var followingAction: Action?
    switch action {
        case let action as FeedDetailActions.FetchData.Start:
            guard !state.refreshing else { break }
            state.showProgressView = action.autoLoad
            state.hasLoadedOnce = true
            state.refreshing = true
            break;
        case let action as FeedDetailActions.FetchData.Done:
            state.refreshing = false
            state.showProgressView = false
            if case let .success(detailInfo) = action.result {
                state.detailInfo = detailInfo ?? FeedDetailInfo()
                state.willLoadPage = 1
            } else {
                // failed
            }
            break;
        default:
            break;
    }
    states[id] = state
    return (states, followingAction)
}
