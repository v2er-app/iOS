//
//  TagDetailReducer.swift
//  TagDetailReducer
//
//  Created by ghui on 2021/9/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func tagDetailStateReducer(_ states: TagDetailStates, _ action: Action) -> (TagDetailStates, Action?) {
    guard action.id != .default else {
        fatalError("action in TagDetail must have id")
        return (states, action)
    }
    let id = action.id
    var states = states
    var state = states[id]!
    var followingAction: Action?
    switch action {
        case let action as TagDetailActions.LoadMore.Start:
            guard !state.loadingMore else { break }
            guard state.hasMoreData else { break }
            state.loadingMore = true
            break;
        case let action as TagDetailActions.LoadMore.Done:
            state.loadingMore = false
            if case let .success(result) = action.result {
                state.willLoadPage += 1
                state.hasMoreData = state.willLoadPage <= result?.totalPage ?? 1
                if state.willLoadPage == 2 {
                    state.model = result!
                } else {
                    let newItems = result!.topics
                    state.model.topics.append(contentsOf: newItems)
                }
            } else {
                // failed
            }
            break;
        default:
            break
    }
    states[id] = state
    return (states, followingAction)
}
