//
//  SearchStateReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func searchStateReducer(_ state: SearchState, _ action: Action?) -> (SearchState, Action?) {
    var state = state
    var updatable = state.updatable
    var followingAction = action
    switch action {
        case let action as SearchActions.Start:
            guard !updatable.refreshing else { break }
            guard state.keyword.notEmpty() else {
                followingAction = nil
                break
            }
            updatable.refreshing = true
            updatable.showLoadingView = true
            updatable.willLoadPage = 1
        case let action as SearchActions.Done:
            updatable.refreshing = false
            updatable.showLoadingView = false
            if case let .success(result) = action.result {
                state.model = result!
                updatable.willLoadPage = 2
                let totalPage: Int = Int(ceil(Double(result!.total / 10)))
                updatable.hasMoreData = updatable.willLoadPage <= totalPage
            } else {
                // failed
            }
        case let action as SearchActions.LoadMoreStart:
            guard !updatable.loadingMore else { break }
            guard updatable.hasMoreData else {
                followingAction = nil
                break
            }
            updatable.loadingMore = true
        case let action as SearchActions.LoadMoreDone:
            updatable.loadingMore = false
            if case let .success(result) = action.result {
                updatable.willLoadPage += 1
                let totalPage: Int = Int(ceil(Double(result!.total / 10)))
                updatable.hasMoreData = updatable.willLoadPage <= totalPage
                if let hints = result?.hits {
                    state.model!.hits.append(contentsOf: hints)
                }
            } else {
                // failed
            }
            break
        default:
            break
    }
    state.updatable = updatable
    return (state, followingAction)
}

struct SearchActions {
    static let R: Reducer = .search

    struct Start: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let result = await SearchActions.loadData(in: store)
            dispatch(Done(result: result))
        }
    }

    struct Done: Action {
        var target: Reducer = R
        let result: APIResult<SearchState.Model>
    }

    struct LoadMoreStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let result = await SearchActions.loadData(in: store)
            dispatch(LoadMoreDone(result: result))
        }
    }

    struct LoadMoreDone: Action {
        var target: Reducer = R
        let result: APIResult<SearchState.Model>
    }


    private static func loadData(in store: Store, loadMore: Bool = false) async -> APIResult<SearchState.Model> {
        let state = store.appState.searchState
        var params = Params()
        params["from"] = ((state.updatable.willLoadPage - 1) * 10).string
        params["q"] = state.keyword
        params["sort"] = state.sortWay
        let result: APIResult<SearchState.Model> = await APIService.shared
            .jsonGet(endpoint: .search, params)
        return result
    }
}
