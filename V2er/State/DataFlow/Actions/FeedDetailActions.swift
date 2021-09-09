//
//  FeedDetailActions.swift
//  FeedDetailActions
//
//  Created by ghui on 2021/9/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedDetailActions {
    static let reducer: Reducer = .feeddetail

    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = reducer

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
            var target: Reducer = reducer
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

}
