//
//  UserDetailActions.swift
//  UserDetailActions
//
//  Created by ghui on 2021/9/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct UserDetailActions {
    static let R: Reducer = .userdetail

    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let userId: String?
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<UserDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .userPage(userName: userId ?? .default))
                dispatch(action: FetchData.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            let result: APIResult<UserDetailInfo>
        }
    }
}
