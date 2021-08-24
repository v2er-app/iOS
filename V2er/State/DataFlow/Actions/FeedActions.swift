//
//  FeedActions.swift
//  FeedActions
//
//  Created by ghui on 2021/8/21.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedActions {

    struct FetchData {
        struct Start: AwaitAction {
            let tab: Tab = .all
            var page: Int = 0

            func execute(in store: Store) async {
                let result: APIResult<NewsListInfo> = await APIService.shared
                    .htmlGet(endpoint: .tab, params: ["tab": tab.rawValue])
                dispatch(action: FetchData.Done(result: result))
            }
        }

        struct Done: Action {
            let result: APIResult<NewsListInfo>
        }
    }

}
