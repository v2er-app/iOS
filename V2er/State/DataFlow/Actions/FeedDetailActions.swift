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

    struct HTMLRendered: Action {
        var target: Reducer = R
    }

}
