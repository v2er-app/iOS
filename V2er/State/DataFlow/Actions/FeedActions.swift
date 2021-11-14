//
//  FeedActions.swift
//  FeedActions
//
//  Created by ghui on 2021/8/21.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedActions {
    static let reducer: Reducer = .feed
    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = reducer
            let tab: Tab = .all
            var page: Int = 0
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<FeedInfo> = await APIService.shared
                    .htmlGet(endpoint: .tab, ["tab": tab.rawValue])
                dispatch(FetchData.Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = reducer
            
            let result: APIResult<FeedInfo>
        }
    }

    struct LoadMore {
        struct Start: AwaitAction {
            var target: Reducer = reducer
            var willLoadPage: Int = 1

            init(_ willLoadPage: Int) {
                self.willLoadPage = willLoadPage
            }

            func execute(in store: Store) async {
                let endpoint: Endpoint = willLoadPage >= 1 ? .recent : .tab
                let result: APIResult<FeedInfo> = await APIService.shared
                    .htmlGet(endpoint: endpoint, ["p": willLoadPage.string])
                dispatch(FeedActions.LoadMore.Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = reducer
            let result: APIResult<FeedInfo>
        }
    }

}
