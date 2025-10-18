//
//  MeActions.swift
//  V2er
//
//  Created by ghui on 2021/9/29.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct MeActions {
    private static let R: Reducer = .me

    struct FetchBalance {
        struct Start: AwaitAction {
            var target: Reducer = R

            func execute(in store: Store) async {
                let result: APIResult<BalanceInfo> = await APIService.shared
                    .htmlGet(endpoint: .balance)
                dispatch(FetchBalance.Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            let result: APIResult<BalanceInfo>
        }
    }
}
