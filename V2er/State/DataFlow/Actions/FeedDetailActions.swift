//
//  FeedDetailActions.swift
//  FeedDetailActions
//
//  Created by ghui on 2021/9/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedDetailActions {
    struct FetchData {
        struct Start: AwaitAction {
            let id: String?
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<FeedDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .topic(id: id ?? .default))
                dispatch(action: FetchData.Done(result: result))
            }
        }

        struct Done: Action {
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
