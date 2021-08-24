//
//  FeedReducer.swift
//  FeedReducer
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func feedStateReducer(_ state: FeedState, _ action: Action) -> (FeedState, Action?) {
    var state = state
    var followingAction: Action?
    if action is AsyncAction { followingAction = action }
    switch action {
        case _ as FeedActions.FetchData.Start:
            guard !state.loading else { break }
            state.loading = true
        case let action as FeedActions.FetchData.Done:
            state.loading = false
            if case let .success(newsInfo) = action.result {
                state.newsInfo = newsInfo
            } else {
                // Loaded failed
            }
        default:
            break
    }
    return (state, followingAction)
}
