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
                } else {
                    let newItems = result!.topics
                    state.model.topics.append(contentsOf: newItems)
                }
            } else {
                // failed
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
                let result: APIResult<TagDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .tagDetail(tagId: tagId ?? .default), ["p" : willLoadPage.string])
                dispatch(LoadMore.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            let result: APIResult<TagDetailInfo>
        }
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
