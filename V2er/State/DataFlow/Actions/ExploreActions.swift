//
//  ExploreActions.swift
//  ExploreActions
//
//  Created by ghui on 2021/9/2.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct ExploreActions {
    static let reducer: Reducer = .explore

    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = reducer

            var autoLoad: Bool = false
            
            func execute(in store: Store) async {
                let result: APIResult<ExploreInfo> = await APIService.shared
                    .htmlGet(endpoint: .explore)
                dispatch(FetchData.Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = reducer

            let result: APIResult<ExploreInfo>
        }
    }

}
