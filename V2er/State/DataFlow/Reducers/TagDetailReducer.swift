//
//  TagDetailReducer.swift
//  TagDetailReducer
//
//  Created by ghui on 2021/9/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func tagDetailStateReducer(_ states: TagDetailStates, _ action: Action) -> (TagDetailStates, Action?) {
    guard action.id != .default else {
        fatalError("action in TagDetail must have id")
    }
    let id = action.id
    var states = states
    var state = states[id]!
    var followingAction: Action?
    switch action {
        case let action as TagDetailActions.LoadMore.Start:
            guard !state.loadingMore else { break }
            guard state.hasMoreData else { break }
            state.showProgressView = action.autoLoad
            state.hasLoadedOnce = true
            state.loadingMore = true
            break;
        case let action as TagDetailActions.LoadMore.Done:
            state.loadingMore = false
            state.showProgressView = false
            if case let .success(result) = action.result {
                state.willLoadPage += 1
                state.hasMoreData = state.willLoadPage <= result?.totalPage ?? 1
                if state.willLoadPage == 2 {
                    state.model = result!
                    state.dataSource = action.source
                } else {
                    let newItems = result!.topics
                    state.model.topics.append(contentsOf: newItems)
                }
            } else {
                // failed
            }
        case let action as TagDetailActions.InjectActionMetadata:
            let html = action.htmlInfo
            // Merge star-related metadata from HTML
            state.model.starLink = html.starLink
            state.model.hasStared = html.hasStared
            // Update totalPage if HTML has more accurate pagination
            if html.totalPage > state.model.totalPage {
                state.model.totalPage = html.totalPage
                state.hasMoreData = state.willLoadPage <= html.totalPage
            }
        case let action as TagDetailActions.StarNodeDone:
            if action.success {
                Toast.show(action.originalStared ? "取消成功" : "收藏成功")
                state.model.hasStared = !action.originalStared
            } else {
                Toast.show(action.originalStared ? "取消失败" : "收藏失败")
            }
            break;
        default:
            break
    }
    states[id] = state
    return (states, followingAction)
}


struct TagDetailActions {
    static let R: Reducer = .tagdetail

    struct LoadMore {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let tagId: String?
            var willLoadPage: Int = 1
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let nodeName = tagId ?? .default

                guard SettingState.getV2exAccessToken() != nil else {
                    // No token — fallback to HTML
                    let result: APIResult<TagDetailInfo> = await APIService.shared
                        .htmlGet(endpoint: .tagDetail(tagId: nodeName), ["p": willLoadPage.string])
                    dispatch(LoadMore.Done(id: id, result: result))
                    return
                }

                if willLoadPage == 1 {
                    // Phase 1: Fetch node info + topics concurrently
                    async let nodeResult: APIResult<V2Response<V2NodeDetail>> = APIService.shared
                        .v2ApiGet(path: "nodes/\(nodeName)")
                    async let topicsResult: APIResult<V2Response<[V2TopicDetail]>> = APIService.shared
                        .v2ApiGet(path: "nodes/\(nodeName)/topics", params: ["p": "1"])
                    let (nodeRes, topicsRes) = await (nodeResult, topicsResult)

                    if case let .success(nodeResp) = nodeRes,
                       let nodeResp = nodeResp, nodeResp.success,
                       case let .success(topicsResp) = topicsRes,
                       let topicsResp = topicsResp, topicsResp.success {
                        let tagDetailInfo = V2APIAdapter.buildTagDetailInfo(
                            node: nodeResp, topics: topicsResp, page: 1
                        )
                        dispatch(LoadMore.Done(id: id, source: .apiV2, result: .success(tagDetailInfo)))

                        // Phase 2: Background HTML for star metadata
                        let htmlResult: APIResult<TagDetailInfo> = await APIService.shared
                            .htmlGet(endpoint: .tagDetail(tagId: nodeName), ["p": "1"])
                        if case let .success(htmlInfo) = htmlResult, let htmlInfo = htmlInfo {
                            dispatch(InjectActionMetadata(id: id, htmlInfo: htmlInfo))
                        }
                    } else {
                        // API failed — fallback to HTML
                        let result: APIResult<TagDetailInfo> = await APIService.shared
                            .htmlGet(endpoint: .tagDetail(tagId: nodeName), ["p": "1"])
                        dispatch(LoadMore.Done(id: id, result: result))
                    }
                } else {
                    // Pages 2+: Only fetch topics
                    let topicsResult: APIResult<V2Response<[V2TopicDetail]>> = await APIService.shared
                        .v2ApiGet(path: "nodes/\(nodeName)/topics", params: ["p": "\(willLoadPage)"])

                    if case let .success(topicsResp) = topicsResult,
                       let topicsResp = topicsResp, topicsResp.success {
                        let state = store.appState.tagDetailStates[id]
                        let totalPage = state?.model.totalPage ?? 1
                        let tagDetailInfo = V2APIAdapter.buildTagDetailTopics(
                            from: topicsResp, totalPage: totalPage
                        )
                        dispatch(LoadMore.Done(id: id, source: .apiV2, result: .success(tagDetailInfo)))
                    } else {
                        // API failed — fallback to HTML
                        let result: APIResult<TagDetailInfo> = await APIService.shared
                            .htmlGet(endpoint: .tagDetail(tagId: nodeName), ["p": willLoadPage.string])
                        dispatch(LoadMore.Done(id: id, result: result))
                    }
                }
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            var source: DataSource = .html
            let result: APIResult<TagDetailInfo>
        }
    }

    struct InjectActionMetadata: Action {
        var target: Reducer = R
        var id: String
        let htmlInfo: TagDetailInfo
    }

    struct StarNode: AwaitAction {
        var target: Reducer = R
        let id: String

        func execute(in store: Store) async {
            let state = store.appState.tagDetailStates[id]
            let originalStared = state?.model.hasStared ?? false
            Toast.show(originalStared ? "取消中" : "收藏中")
            let result: APIResult<SimpleModel> = await APIService.shared
                .htmlGet(endpoint: .general(url: state?.model.starLink ?? .empty), requestHeaders: Headers.TINY_REFERER)
            var success: Bool = false
            if case .success(_) = result {
                success = true
            }
            dispatch(StarNodeDone(id: id, success: success, originalStared: originalStared))
        }
    }

    struct StarNodeDone: Action {
        var target: Reducer = R
        let id: String
        let success: Bool
        let originalStared: Bool
    }

}
