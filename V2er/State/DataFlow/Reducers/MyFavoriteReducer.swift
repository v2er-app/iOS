//
//  MyFavoriteReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func myFavoriteStateReducer(_ state: MyFavoriteState, _ action: Action) -> (MyFavoriteState, Action?) {
    var state = state
    var updatable: UpdatableState
    switch action {
        case let action as MyFavoriteActions.FetchFeedStart:
            updatable = state.feedState.updatable
            guard !updatable.refreshing else { break }
            updatable.showLoadingView = action.autoLoad
            updatable.hasLoadedOnce = true
            updatable.refreshing = true
            updatable.hasMoreData = true
            state.feedState.updatable = updatable
            break
        case let action as MyFavoriteActions.FetchFeedDone:
            updatable = state.feedState.updatable
            updatable.refreshing = false
            updatable.showLoadingView = false
            if case let .success(model) = action.result {
                state.feedState.model = model!
                updatable.willLoadPage = 2
            } else {
                // failed
            }
            state.feedState.updatable = updatable
        case let action as MyFavoriteActions.LoadMoreFeedStart:
            updatable = state.feedState.updatable
            guard !updatable.refreshing else { break }
            guard !updatable.loadingMore else { break }
            updatable.loadingMore = true
            state.feedState.updatable = updatable
        case let action as MyFavoriteActions.LoadMoreFeedDone:
            updatable = state.feedState.updatable
            updatable.loadingMore = false
            if case let .success(model) = action.result {
                let model = model!
                updatable.willLoadPage += 1
                updatable.hasMoreData = updatable.willLoadPage <= model.totalPage
                state.feedState.model?.items.append(contentsOf: model.items)
            } else {
                updatable.hasMoreData = true
            }
            state.feedState.updatable = updatable
        case let action as MyFavoriteActions.FetchNodeStart:
            updatable = state.nodeState.updatable
            guard !updatable.refreshing else { break }
            updatable.showLoadingView = action.autoLoad
            updatable.hasLoadedOnce = true
            updatable.refreshing = true
            updatable.hasMoreData = true
            state.nodeState.updatable = updatable
            break
        case let action as MyFavoriteActions.FetchNodeDone:
            updatable = state.nodeState.updatable
            updatable.refreshing = false
            updatable.showLoadingView = false
            if case let .success(model) = action.result {
                state.nodeState.model = model!
            } else {
                // failed
            }
            state.nodeState.updatable = updatable
            break
        default:
            break
    }
    return (state, action)
}

struct MyFavoriteActions {
    static let R: Reducer = .myfavorite
    struct FetchFeedStart: AwaitAction {
        var target: Reducer = R
        var autoLoad = false

        func execute(in store: Store) async {
            let result: APIResult<MyFavoriteState.FeedState.Model> =
            await APIService.shared.htmlGet(endpoint: .myFavoriteFeeds)
            dispatch(FetchFeedDone(result: result))
        }
    }

    struct FetchFeedDone: Action {
        var target: Reducer = R
        let result: APIResult<MyFavoriteState.FeedState.Model>
    }

    struct LoadMoreFeedStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let state = store.appState.myFavoriteState.feedState
            let params = ["p" : state.updatable.willLoadPage.string]
            let result: APIResult<MyFavoriteState.FeedState.Model> =
            await APIService.shared.htmlGet(endpoint: .myFavoriteFeeds, params)
            dispatch(LoadMoreFeedDone(result: result))
        }
    }

    struct LoadMoreFeedDone: Action {
        var target: Reducer = R
        let result: APIResult<MyFavoriteState.FeedState.Model>
    }

    struct FetchNodeStart: AwaitAction {
        var target: Reducer = R
        var autoLoad = false

        func execute(in store: Store) async {
            let result: APIResult<MyFavoriteState.NodeState.Model> =
            await APIService.shared.htmlGet(endpoint: .myFavoriteNodes)
            dispatch(FetchNodeDone(result: result))
        }
    }

    struct FetchNodeDone: Action {
        var target: Reducer = R
        let result: APIResult<MyFavoriteState.NodeState.Model>
    }

}
