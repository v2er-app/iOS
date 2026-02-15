//
//  MessageReducer.swift
//  MessageReducer
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func messageStateReducer(_ state: MessageState, _ action: Action) -> (MessageState, Action?) {
    var state = state
    var followingAction: Action?
    guard AccountState.hasSignIn() else {
        followingAction = nil
        return (state, followingAction)
    }
    switch action {
        case let action as MessageActions.FetchStart:

            guard !state.updatableState.refreshing else { break }
            state.updatableState.showLoadingView = action.autoLoad
            state.hasLoadedOnce = true
            state.updatableState.refreshing = true
            break
        case let action as MessageActions.FetchDone:
            state.updatableState.refreshing = false
            state.updatableState.showLoadingView = false
            if case let .success(messageInfo) = action.result {
                state.model = messageInfo!
                state.updatableState.willLoadPage = 2
                state.dataSource = action.source
                dispatch(FeedActions.ClearMsgBadge(), .default)
            } else {
                // failed
            }
        case let action as MessageActions.LoadMoreStart:
            guard !state.updatableState.refreshing else { break }
            guard !state.updatableState.loadingMore else { break }
            state.updatableState.loadingMore = true
        case let action as MessageActions.LoadMoreDone:
            state.updatableState.loadingMore = false
            if case let .success(messageInfo) = action.result {
                let messageInfo = messageInfo!
                state.updatableState.willLoadPage += 1
                state.updatableState.hasMoreData = state.updatableState.willLoadPage <= messageInfo.totalPage
                state.model.items.append(contentsOf: messageInfo.items)
            } else {
                state.updatableState.hasMoreData = true
            }
        default:
            break
    }
    return (state, followingAction)
}


struct MessageActions {
    private static var R: Reducer = .message

    struct FetchStart: AwaitAction {
        var target: Reducer = R
        var autoLoad: Bool = false

        func execute(in store: Store) async {
            guard SettingState.getV2exAccessToken() != nil else {
                // No token — fallback to HTML
                let result: APIResult<MessageInfo> = await APIService.shared
                    .htmlGet(endpoint: .message)
                dispatch(FetchDone(result: result))
                return
            }

            // Phase 1: Fetch via V2 API
            let apiResult: APIResult<V2Response<[V2NotificationDetail]>> = await APIService.shared
                .v2ApiGet(path: "notifications", params: ["p": "1"])

            if case let .success(response) = apiResult,
               let response = response, response.success {
                let messageInfo = V2APIAdapter.buildMessageInfo(from: response, page: 1)
                dispatch(FetchDone(source: .apiV2, result: .success(messageInfo)))
            } else {
                // API failed — fallback to HTML
                let result: APIResult<MessageInfo> = await APIService.shared
                    .htmlGet(endpoint: .message)
                dispatch(FetchDone(result: result))
            }
        }
    }

    struct FetchDone: Action {
        var target: Reducer = R
        var source: DataSource = .html
        let result: APIResult<MessageInfo>
    }

    struct LoadMoreStart: AwaitAction {
        var target: Reducer = R
        func execute(in store: Store) async {
            let state = store.appState.messageState
            let page = state.updatableState.willLoadPage

            guard SettingState.getV2exAccessToken() != nil else {
                let params = ["p": page.string]
                let result: APIResult<MessageInfo> = await APIService.shared
                    .htmlGet(endpoint: .message, params)
                dispatch(LoadMoreDone(result: result))
                return
            }

            let apiResult: APIResult<V2Response<[V2NotificationDetail]>> = await APIService.shared
                .v2ApiGet(path: "notifications", params: ["p": "\(page)"])

            if case let .success(response) = apiResult,
               let response = response, response.success {
                let messageInfo = V2APIAdapter.buildMessageInfo(from: response, page: page)
                dispatch(LoadMoreDone(source: .apiV2, result: .success(messageInfo)))
            } else {
                let params = ["p": page.string]
                let result: APIResult<MessageInfo> = await APIService.shared
                    .htmlGet(endpoint: .message, params)
                dispatch(LoadMoreDone(result: result))
            }
        }
    }

    struct LoadMoreDone: Action {
        var target: Reducer = R
        var source: DataSource = .html
        let result: APIResult<MessageInfo>
    }

}
