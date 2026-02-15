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
                let userName = id ?? .default

                // API v2 GET member only works for self
                guard AccountState.isSelf(userName: userName),
                      SettingState.getV2exAccessToken() != nil else {
                    let result: APIResult<UserDetailInfo> = await APIService.shared
                        .htmlGet(endpoint: .userPage(userName: userName))
                    dispatch(FetchData.Done(id: id, result: result))
                    return
                }

                // Phase 1: Fetch own profile via V2 API
                let apiResult: APIResult<V2Response<V2MemberDetail>> = await APIService.shared
                    .v2ApiGet(path: "member")

                if case let .success(response) = apiResult,
                   let response = response, response.success {
                    let userDetailInfo = V2APIAdapter.buildUserDetailInfo(from: response)
                    dispatch(FetchData.Done(id: id, source: .apiV2, result: .success(userDetailInfo)))

                    // Phase 2: Background HTML for topics, replies, and action metadata
                    let htmlResult: APIResult<UserDetailInfo> = await APIService.shared
                        .htmlGet(endpoint: .userPage(userName: userName))
                    if case let .success(htmlInfo) = htmlResult, let htmlInfo = htmlInfo {
                        dispatch(InjectHtmlData(id: id, htmlInfo: htmlInfo))
                    }
                } else {
                    // API failed — fallback to HTML
                    let result: APIResult<UserDetailInfo> = await APIService.shared
                        .htmlGet(endpoint: .userPage(userName: userName))
                    dispatch(FetchData.Done(id: id, result: result))
                }
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            var source: DataSource = .html
            let result: APIResult<UserDetailInfo>
        }

        struct InjectHtmlData: Action {
            var target: Reducer = R
            var id: String
            let htmlInfo: UserDetailInfo
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
