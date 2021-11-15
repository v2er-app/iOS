//
//  FeedDetailActions.swift
//  FeedDetailActions
//
//  Created by ghui on 2021/9/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedDetailActions {
    static let R: Reducer = .feeddetail

    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let feedId: String?
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<FeedDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .topic(id: feedId ?? .default), ["p": 1.string])
                dispatch(FetchData.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String

            let result: APIResult<FeedDetailInfo>
        }
    }

    struct LoadMore {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let feedId: String?
            var willLoadPage: Int = 2

            func execute(in store: Store) async {
                let result: APIResult<FeedDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .topic(id: feedId ?? .default), ["p" : willLoadPage.string])
                dispatch(LoadMore.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            let result: APIResult<FeedDetailInfo>
        }
    }

    struct StarTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            let state = store.appState.feedDetailStates[id]
            let once = state?.model.once
            let headers: Params = [Headers.REFERER : Headers.topicReferer(id)]
            let hadStared = state?.model.headerInfo?.hadStared ?? false

            let result: APIResult<FeedDetailInfo> = await APIService.shared
                .htmlGet(endpoint: hadStared ? .unStarTopic(id: id): .starTopic(id: id),
                         ["once": once!],
                         requestHeaders: headers)
            dispatch(StarTopicDone(id: id, hadStared: hadStared, result: result))
        }
    }

    struct StarTopicDone: Action {
        var target: Reducer = R
        var id: String
        var hadStared: Bool

        let result: APIResult<FeedDetailInfo>
    }

    struct ThanksAuthor: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            let state = store.appState.feedDetailStates[id]
            let once = state?.model.once

            let step1Result: APIResult<SimpleModel>  = await APIService.shared
                .post(endpoint: .thanksAuthor(id: id), ["once": once!])

            var success: Bool = false
            var toast = "感谢发送失败"
            if case let .success(result) = step1Result {
                if result!.isValid() {
                    toast = "感谢发送成功"
                    success = true
                }
            }
            dispatch(ThanksAuthorDone(id: id, success: success))
        }
    }

    struct ThanksAuthorDone: Action {
        var target: Reducer = R
        var id: String
        let success: Bool
    }

    struct IgnoreTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            let state = store.appState.feedDetailStates[id]
            let once = state?.model.once
            let result: APIResult<FeedInfo> = await APIService.shared
                .htmlGet(endpoint: .ignoreTopic(id: id), ["once": once!])
            var ignored = false
            if case let .success(result) = result {
                ignored = result?.isValid() ?? false
            }
            dispatch(IgnoreTopicDone(id: id, ignored: ignored))
        }

    }

    struct IgnoreTopicDone: Action {
        var target: Reducer = R
        var id: String
        let ignored: Bool
    }

}
