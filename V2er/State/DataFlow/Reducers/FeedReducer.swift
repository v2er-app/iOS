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
    switch action {
        case let action as FeedActions.FetchData.Start:
            guard !state.refreshing else { break }
            state.showProgressView = action.autoLoad
            state.hasLoadedOnce = true
            state.refreshing = true
        case let action as FeedActions.FetchData.Done:
            state.refreshing = false
            state.showProgressView = false
            if case let .success(newsInfo) = action.result {
                state.feedInfo = newsInfo ?? FeedInfo()
                state.willLoadPage = 1
            } else {
                // Loaded failed
            }
        case let action as FeedActions.LoadMore.Start:
            guard !state.refreshing else { break }
            guard !state.loadingMore else { break }
            state.loadingMore = true
            break
        case let action as FeedActions.LoadMore.Done:
            state.loadingMore = false
            state.hasMoreData = true // todo check vary tabs
            if case let .success(newsInfo) = action.result {
                state.feedInfo.append(feedInfo: newsInfo!)
                state.willLoadPage += 1
            } else {
                // failed
            }
            break
        default:
            break
    }
    return (state, followingAction)
}
