//
//  FeedDetailReducer.swift
//  FeedDetailReducer
//
//  Created by ghui on 2021/9/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func feedDetailStateReducer(_ states: FeedDetailStates, _ action: Action) -> (FeedDetailStates, Action?) {
    guard action.id != .default else {
        fatalError("action in FeedDetail must have id")
        return (states, action)
    }
    let id = action.id
    var states = states
    var state = states[id]!
    var followingAction: Action?
    switch action {
        case let action as FeedDetailActions.FetchData.Start:
            guard !state.refreshing else { break }
            state.showProgressView = action.autoLoad
            state.hasLoadedOnce = true
            state.refreshing = true
        case let action as FeedDetailActions.FetchData.Done:
            state.refreshing = false
            state.showProgressView = false
            if case let .success(result) = action.result {
                state.model = result!
                state.model.injectId(id)
                state.willLoadPage = 2
                state.hasMoreData = state.willLoadPage <= result?.headerInfo?.totalPage ?? 1
            }
        case let action as FeedDetailActions.LoadMore.Start:
            guard !state.refreshing else { break }
            guard !state.loadingMore else { break }
            guard state.hasMoreData else {
                followingAction = nil
                break
            }
            state.loadingMore = true
        case let action as FeedDetailActions.LoadMore.Done:
            state.loadingMore = false
            if case let .success(result) = action.result {
                state.willLoadPage += 1
                state.hasMoreData = state.willLoadPage <= result?.headerInfo?.totalPage ?? 1
                state.model.replyInfo.append(result?.replyInfo)
            } else {
                state.hasMoreData = true
            }
        case let action as FeedDetailActions.ReplyDone:
            var toast: String
            if case let .success(result) = action.result {
                toast = "回复成功"
                state.replyContent = .empty
                state.model.replyInfo.append(result?.replyInfo, afterReply: true)
                state.willLoadPage = state.model.headerInfo!.currentPage + 1
                state.hasMoreData = state.willLoadPage <= result!.headerInfo!.totalPage
            } else {
                toast = "回复失败"
            }
            Toast.show(toast)
        case let action as OnAppearChangeAction:
            if action.isAppear {
                state.refCounts += 1
            } else {
                state.refCounts -= 1
            }
        case let action as InstanceDestoryAction:
            if state.refCounts == 0 {
                state.reseted = true
            }
        case let action as FeedDetailActions.StarTopicDone:
            let toast = action.hadStared ? "取消收藏" : "收藏"
            if case let .success(result) = action.result {
                state.model.headerInfo?.update(result?.headerInfo)
                Toast.show(toast + "成功")
            } else {
                Toast.show(toast + "失败")
            }
        case let action as FeedDetailActions.ThanksAuthorDone:
            state.model.headerInfo?.hadThanked = true
            Toast.show(action.success ? "感谢发送成功" : "感谢发送失败")
        case let action as FeedDetailActions.IgnoreTopicDone:
            state.ignored = action.ignored
            Toast.show(action.ignored ? "忽略成功" : "忽略失败")
        case let action as FeedDetailActions.ReportTopicDone:
            state.model.hasReported = action.reported
            Toast.show(action.reported ? "举报成功" : "举报失败")
        default:
            break;
    }
    if state.reseted {
        states.removeValue(forKey: id)
    } else {
        states[id] = state
    }
    return (states, followingAction)
}
