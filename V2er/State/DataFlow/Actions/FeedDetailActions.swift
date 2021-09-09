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

            var id: String?
            let feedId: String?
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<FeedDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .topic(id: feedId ?? .default))
                dispatch(action: FetchData.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String?

            let result: APIResult<FeedDetailInfo>
        }
    }

    struct LoadMore {
//        struct Start: AwaitAction {
//            func execute(in store: Store) async {
//
//            }
//        }
//
//        struct Done: Action {
//
//        }
    }

    struct OnPageClosed: Action {
        var target: Reducer = R
        var id: String?
        // state refAccounts - 1
    }

    struct OnAppearChange: Action {
        var target: Reducer = R
        var id: String?
        var isAppear: Bool
    }

}
