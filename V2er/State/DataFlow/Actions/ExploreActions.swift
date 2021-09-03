//
//  ExploreActions.swift
//  ExploreActions
//
//  Created by ghui on 2021/9/2.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct ExploreActions {

    struct FetchData {
        struct Start: AwaitAction {
            var autoLoad: Bool = false
            
            func execute(in store: Store) async {
                let result: APIResult<ExploreInfo> = await APIService.shared
                    .htmlGet(endpoint: .explore)
                dispatch(action: FetchData.Done(result: result))
            }
        }

        struct Done: Action {
            let result: APIResult<ExploreInfo>
        }
    }

}
