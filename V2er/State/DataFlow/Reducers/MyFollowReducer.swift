//
//  MyFollowReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func myFollowStateReducer(_ state: MyFollowState, _ action: Action) -> (MyFollowState, Action?) {
    var state = state
    var updatable = state.updatableState
    var followingAction: Action?
    switch action {
        case let action as MyFollowActions.FetchStart:
            guard !updatable.refreshing else { break }
            updatable.showLoadingView = action.autoLoad
            updatable.hasLoadedOnce = true
            updatable.refreshing = true
            updatable.hasMoreData = true
        case let action as MyFollowActions.FetchDone:
            updatable.refreshing = false
            updatable.showLoadingView = false
            if case let .success(model) = action.result {
                state.model = model!
                updatable.willLoadPage = 2
            } else {
                // failed
            }
        case let action as MyFollowActions.LoadMoreStart:
            guard !updatable.refreshing else { break }
            guard !updatable.loadingMore else { break }
            updatable.loadingMore = true
        case let action as MyFollowActions.LoadMoreDone:
            updatable.loadingMore = false
            if case let .success(model) = action.result {
                let model = model!
                updatable.willLoadPage += 1
                updatable.hasMoreData = updatable.willLoadPage <= model.totalPage
                state.model?.items.append(contentsOf: model.items)
            } else {
                updatable.hasMoreData = true
            }
        default:
            break
    }
    state.updatableState = updatable
    return (state, followingAction)
}

struct MyFollowActions {
    private static var R: Reducer = .myfollow

    struct FetchStart: AwaitAction {
        var target: Reducer = R
        var autoLoad = false

        func execute(in store: Store) async {
            let result: APIResult<MyFollowInfo> = await APIService.shared
                .htmlGet(endpoint: .myFollowing)
            dispatch(FetchDone(result: result))
        }
    }

    struct FetchDone: Action {
        var target: Reducer = R
        let result: APIResult<MyFollowInfo>
    }

    struct LoadMoreStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let state = store.appState.myFollowState
            let params = ["p": state.updatableState.willLoadPage.string]
            let result: APIResult<MyFollowInfo> = await APIService.shared
                .htmlGet(endpoint: .myFollowing, params)
            dispatch(LoadMoreDone(result: result))
        }
    }

    struct LoadMoreDone: Action {
        var target: Reducer = R
        let result: APIResult<MyFollowInfo>
    }
}
