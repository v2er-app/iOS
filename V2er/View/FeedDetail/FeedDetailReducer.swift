//
//  FeedDetailReducer.swift
//  FeedDetailReducer
//
//  Created by ghui on 2021/9/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func feedDetailStateReducer(_ state: FeedDetailState, _ action: Action) -> (FeedDetailState, Action?) {
    var state = state
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
    return (state, followingAction)
}
