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
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<UserDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .userPage(userName: id ?? .default))
                dispatch(FetchData.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            let result: APIResult<UserDetailInfo>
        }
    }

    struct Follow: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            if AccountState.isSelf(userName: id) {
                Toast.show("无法关注自己")
                return
            }
            let state = store.appState.userDetailStates[id]!
            let followed = state.model.hasFollowed
            Toast.show(followed ? "取消中" : "关注中")
            let result: APIResult<UserDetailInfo> = await APIService.shared
                .htmlGet(endpoint: .general(url: state.model.followUrl),
                         requestHeaders: Headers.userReferer(id))
            dispatch(FollowDone(id: id, originalFollowed: followed, result: result))
        }
    }

    struct FollowDone: Action {
        var target: Reducer = R
        var id: String
        let originalFollowed: Bool

        let result: APIResult<UserDetailInfo>
    }

    struct BlockUser: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            if AccountState.isSelf(userName: id) {
                Toast.show("无法屏蔽自己")
                return
            }
            let state = store.appState.userDetailStates[id]!
            let hadBlocked = state.model.hasBlocked
            Toast.show(hadBlocked ? "取消屏蔽" : "屏蔽中")
            let result: APIResult<UserDetailInfo> = await APIService.shared
                .htmlGet(endpoint: .general(url: state.model.blockUrl),
                         requestHeaders: Headers.userReferer(id))
            dispatch(BlockUserDone(id: id, originalBlocked: hadBlocked, result: result))
        }

    }

    struct BlockUserDone: Action {
        var target: Reducer = R
        var id: String
        let originalBlocked: Bool
        let result: APIResult<UserDetailInfo>
    }

}
