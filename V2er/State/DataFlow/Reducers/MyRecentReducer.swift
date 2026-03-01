//
//  MyRecentReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func myRecentStateReducer(_ state: MyRecentState, _ action: Action) -> (MyRecentState, Action?) {
    var state = state

    switch action {
        case let action as MyRecentActions.LoadDataStart:
            guard !state.loading else { break }
            state.loading = true
        case let action as MyRecentActions.LoadDataDone:
            state.loading = false
            state.records = action.result
        case let action as MyRecentActions.RecordAction:
            break
        default:
            break
    }
    return (state, action)
}

struct MyRecentActions {
    static let R: Reducer = .myrecent

    struct LoadDataStart: AwaitAction {
        var target: Reducer = R

        @MainActor
        func execute(in store: Store) async {
            let username = AccountManager.shared.activeUsername ?? ""
            let browsingRecords = SyncDataService.fetchBrowsingRecords(for: username)
            let result: [MyRecentState.Record] = browsingRecords.map { br in
                MyRecentState.Record(
                    id: br.topicId,
                    title: br.title,
                    avatar: br.avatar,
                    userName: br.authorName,
                    replyUpdate: br.replyUpdate,
                    nodeName: br.nodeName,
                    nodeId: br.nodeId,
                    replyNum: br.replyNum
                )
            }
            dispatch(LoadDataDone(result: result.isEmpty ? nil : result))
        }
    }

    struct LoadDataDone: Action {
        var target: Reducer = R
        let result: [MyRecentState.Record]?
    }

    struct RecordAction: AwaitAction {
        var target: Reducer = R
        let data: FeedInfo.Item?

        @MainActor
        func execute(in store: Store) async {
            guard let data = data else { return }
            let username = AccountManager.shared.activeUsername ?? ""
            SyncDataService.saveBrowsingRecord(
                topicId: data.id,
                username: username,
                title: data.title ?? "",
                avatar: data.avatar ?? "",
                authorName: data.userName ?? "",
                nodeName: data.nodeName ?? "",
                nodeId: data.nodeId ?? "",
                replyNum: data.replyNum ?? ""
            )
            log("Recorded browsing: \(data.id)")
        }
    }

}
