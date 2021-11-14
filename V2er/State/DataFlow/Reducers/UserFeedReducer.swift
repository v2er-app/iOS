//
//  UserFeedReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func userFeedStateReducer(_ states: UserFeedStates, _ action: Action) -> (UserFeedStates, Action?) {
    guard action.id != .default else {
        fatalError("action in FeedDetail must have id")
        return (states, action)
    }
    let id = action.id
    var states = states
    var state = states[id]!
    var followingAction: Action?
    switch action {
        case let action as UserFeedActions.FetchStart:
            guard !state.updatableState.refreshing else { break }
            state.updatableState.showLoadingView = action.autoLoad
            state.hasLoadedOnce = true
            state.updatableState.refreshing = true
            state.updatableState.hasMoreData = true
        case let action as UserFeedActions.FetchDone:
            state.updatableState.refreshing = false
            state.updatableState.showLoadingView = false
            if case let .success(model) = action.result {
                state.model = model!
                state.updatableState.willLoadPage = 2
            } else {
                // failed
            }
        case let action as UserFeedActions.LoadMoreStart:
            guard !state.updatableState.refreshing else { break }
            guard !state.updatableState.loadingMore else { break }
            state.updatableState.loadingMore = true
        case let action as UserFeedActions.LoadMoreDone:
            state.updatableState.loadingMore = false
            if case let .success(model) = action.result {
                let model = model!
                state.updatableState.willLoadPage += 1
                state.updatableState.hasMoreData = state.updatableState.willLoadPage <= model.totalPage
                state.model.items.append(contentsOf: model.items)
            } else {
                state.updatableState.hasMoreData = true
            }
        default:
            break
    }
    states[id] = state
    return (states, action)
}

struct UserFeedActions {
    private static var R: Reducer = .userfeed

    struct FetchStart: AwaitAction {
        var target: Reducer = R
        let id: String
        let userId: String
        var autoLoad = false

        func execute(in store: Store) async {
            let result: APIResult<UserFeedInfo> = await APIService.shared
                .htmlGet(endpoint: .topics(userName: userId))
            dispatch(FetchDone(id: id, result: result))
        }
    }

    struct FetchDone: Action {
        var target: Reducer = R
        var id: String
        let result: APIResult<UserFeedInfo>
    }

    struct LoadMoreStart: AwaitAction {
        var target: Reducer = R
        let id: String
        let userId: String

        func execute(in store: Store) async {
            let state = store.appState.userFeedStates[id]!
            let params = ["p": state.updatableState.willLoadPage.string]
            let result: APIResult<UserFeedInfo> = await APIService.shared
                .htmlGet(endpoint: .topics(userName: userId), params)
            dispatch(LoadMoreDone(id: id, result: result))
        }
    }

    struct LoadMoreDone: Action {
        var target: Reducer = R
        let id: String
        let result: APIResult<UserFeedInfo>
    }

}

