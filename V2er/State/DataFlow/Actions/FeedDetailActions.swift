//
//  FeedDetailActions.swift
//  FeedDetailActions
//
//  Created by ghui on 2021/9/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedDetailActions {
    static let R: Reducer = .feeddetail

    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let feedId: String?
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<FeedDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .topic(id: feedId ?? .default), ["p": 1.string])
                dispatch(FetchData.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String

            let result: APIResult<FeedDetailInfo>
        }
    }

    struct LoadMore {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let feedId: String?
            var willLoadPage: Int = 2

            func execute(in store: Store) async {
                let result: APIResult<FeedDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .topic(id: feedId ?? .default), ["p" : willLoadPage.string])
                dispatch(LoadMore.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            let result: APIResult<FeedDetailInfo>
        }
    }

    struct StarTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能收藏主题"))
                return
            }

            let state = store.appState.feedDetailStates[id]
            let hadStared = state?.model.headerInfo?.hadStared ?? false
            Toast.show(hadStared ? "取消收藏" : "收藏中")
            guard let once = state?.model.once else {
                Toast.show("操作失败，请刷新页面")
                return
            }
            let headers: Params = Headers.topicReferer(id)

            let result: APIResult<FeedDetailInfo> = await APIService.shared
                .htmlGet(endpoint: hadStared ? .unStarTopic(id: id): .starTopic(id: id),
                         ["once": once],
                         requestHeaders: headers)
            dispatch(StarTopicDone(id: id, hadStared: hadStared, result: result))
        }
    }

    struct StarTopicDone: Action {
        var target: Reducer = R
        var id: String
        var hadStared: Bool

        let result: APIResult<FeedDetailInfo>
    }

    struct ThanksAuthor: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能感谢作者"))
                return
            }

            Toast.show("发送中")
            let state = store.appState.feedDetailStates[id]
            guard let once = state?.model.once else {
                Toast.show("操作失败，请刷新页面")
                return
            }

            let step1Result: APIResult<SimpleModel>  = await APIService.shared
                .post(endpoint: .thanksAuthor(id: id), ["once": once])

            var success: Bool = false
            var toast = "感谢发送失败"
            if case let .success(result) = step1Result {
                if result!.isValid() {
                    toast = "感谢发送成功"
                    success = true
                }
            }
            dispatch(ThanksAuthorDone(id: id, success: success))
        }
    }

    struct ThanksAuthorDone: Action {
        var target: Reducer = R
        var id: String
        let success: Bool
    }

    struct IgnoreTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能忽略主题"))
                return
            }

            Toast.show("忽略中")
            let state = store.appState.feedDetailStates[id]
            guard let once = state?.model.once else {
                Toast.show("操作失败，请刷新页面")
                return
            }
            let result: APIResult<FeedInfo> = await APIService.shared
                .htmlGet(endpoint: .ignoreTopic(id: id), ["once": once])
            var ignored = false
            if case let .success(result) = result {
                ignored = result?.isValid() ?? false
            }
            dispatch(IgnoreTopicDone(id: id, ignored: ignored))
        }

    }

    struct IgnoreTopicDone: Action {
        var target: Reducer = R
        var id: String
        let ignored: Bool
    }

    struct ReportTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能举报主题"))
                return
            }

            Toast.show("举报中")
            guard let state = store.appState.feedDetailStates[id],
                  let reportLink = state.model.reportLink else {
                Toast.show("操作失败，请刷新页面")
                return
            }

            let result: APIResult<DailyInfo> = await APIService.shared
                .htmlGet(endpoint: .general(url: reportLink),
                         requestHeaders: Headers.TINY_REFERER)
            var reported = false
            if case let .success(result) = result {
                reported = result?.isValid() ?? false
            }
            dispatch(ReportTopicDone(id: id, reported: reported))
        }
    }

    struct ReportTopicDone: Action {
        var target: Reducer = R
        var id: String
        let reported: Bool
    }

    struct ReplyTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能回复主题"))
                return
            }

            Toast.show("回复中")
            guard let state = store.appState.feedDetailStates[id] else {
                Toast.show("操作失败，请刷新页面")
                return
            }

            guard let once = state.model.once else {
                Toast.show("操作失败，请刷新页面")
                return
            }

            var params: Params = Params()
            params["once"] = once
            params["content"] = state.replyContent

            let result: APIResult<FeedDetailInfo> = await APIService.shared
                .post(endpoint: .replyTopic(id: id), params)
            dispatch(ReplyDone(id: id, result: result))
        }
    }

    struct ReplyDone: Action {
        var target: Reducer = R
        let id: String
        let result: APIResult<FeedDetailInfo>
    }

    struct StickyTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能置顶主题"))
                return
            }

            Toast.show("置顶中")
            guard let state = store.appState.feedDetailStates[id],
                  let stickyStr = state.model.stickyStr,
                  stickyStr.notEmpty() else {
                Toast.show("操作失败，请刷新页面")
                return
            }

            // Parse the onclick string to get the URL
            // Format: "if (confirm('...')) { location.href = '/sticky/topic/123456?once=xxx'; }"
            guard let sIndex = stickyStr.index(of: "/sticky/topic/"),
                  let eIndex = stickyStr.lastIndex(of: "'") else {
                Toast.show("操作失败，无法解析链接")
                return
            }
            let stickyLink = String(stickyStr[sIndex..<eIndex])

            let result: APIResult<FeedDetailInfo> = await APIService.shared
                .htmlGet(endpoint: .general(url: stickyLink),
                         requestHeaders: Headers.topicReferer(id))
            var success = false
            if case let .success(result) = result {
                success = result?.isValid() ?? false
            }
            dispatch(StickyTopicDone(id: id, success: success))
        }
    }

    struct StickyTopicDone: Action {
        var target: Reducer = R
        var id: String
        let success: Bool
    }

    struct FadeTopic: AwaitAction {
        var target: Reducer = R
        var id: String

        func execute(in store: Store) async {
            // Check if user is logged in
            guard AccountState.hasSignIn() else {
                Toast.show("请先登录")
                dispatch(LoginActions.ShowLoginPageAction(reason: "需要登录才能下沉主题"))
                return
            }

            Toast.show("下沉中")
            guard let state = store.appState.feedDetailStates[id],
                  let fadeStr = state.model.fadeStr,
                  fadeStr.notEmpty() else {
                Toast.show("操作失败，请刷新页面")
                return
            }

            // Parse the onclick string to get the URL
            // Format: "if (confirm('...')) { location.href = '/fade/topic/123456?once=xxx'; }"
            guard let sIndex = fadeStr.index(of: "/fade/topic/"),
                  let eIndex = fadeStr.lastIndex(of: "'") else {
                Toast.show("操作失败，无法解析链接")
                return
            }
            let fadeLink = String(fadeStr[sIndex..<eIndex])

            let result: APIResult<FeedDetailInfo> = await APIService.shared
                .htmlGet(endpoint: .general(url: fadeLink),
                         requestHeaders: Headers.topicReferer(id))
            var success = false
            if case let .success(result) = result {
                success = result?.isValid() ?? false
            }
            dispatch(FadeTopicDone(id: id, success: success))
        }
    }

    struct FadeTopicDone: Action {
        var target: Reducer = R
        var id: String
        let success: Bool
    }

}
