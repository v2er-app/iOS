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
                // Ensure no duplicate replies after initial load
                state.model.replyInfo.items = state.model.replyInfo.items.uniqued()
                state.willLoadPage = 2
                state.hasMoreData = state.willLoadPage <= result?.headerInfo?.totalPage ?? 1
            }
        case let action as FeedDetailActions.FetchData.InjectActionMetadata:
            let html = action.htmlInfo
            state.model.once = html.once
            state.model.reportLink = html.reportLink
            state.model.hasReported = html.hasReported
            state.model.fadeStr = html.fadeStr
            state.model.stickyStr = html.stickyStr
            if let htmlHeader = html.headerInfo {
                state.model.headerInfo?.hadStared = htmlHeader.hadStared
                state.model.headerInfo?.hadThanked = htmlHeader.hadThanked
                state.model.headerInfo?.isThankable = htmlHeader.isThankable
                state.model.headerInfo?.favoriteLink = htmlHeader.favoriteLink
                state.model.headerInfo?.appendText = htmlHeader.appendText
                // Update totalPage from HTML if it's more accurate
                if htmlHeader.totalPage > (state.model.headerInfo?.totalPage ?? 1) {
                    state.model.headerInfo?.totalPage = htmlHeader.totalPage
                    state.hasMoreData = state.willLoadPage <= htmlHeader.totalPage
                }
            }
            // Merge reply love counts and thank status from HTML
            for htmlReply in html.replyInfo.items {
                if let idx = state.model.replyInfo.items.firstIndex(where: { $0.replyId == htmlReply.replyId }) {
                    state.model.replyInfo.items[idx].love = htmlReply.love
                    state.model.replyInfo.items[idx].hadThanked = htmlReply.hadThanked
                }
            }
            // Inject postscripts from HTML (not available via API)
            if !html.postscripts.isEmpty && state.model.postscripts.isEmpty {
                state.model.postscripts = html.postscripts
            }
            // Inject problem info from HTML (not available via API)
            if let problem = html.problem, state.model.problem == nil {
                state.model.problem = problem
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
                // Use uniqued() to prevent duplicate replies when LoadMore is triggered multiple times
                state.model.replyInfo.append(result?.replyInfo)
                state.model.replyInfo.items = state.model.replyInfo.items.uniqued()
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
        case let action as FeedDetailActions.StickyTopicDone:
            if action.success {
                state.model.stickyStr = nil // Disable sticky button after success
            }
            Toast.show(action.success ? "置顶 10 分钟成功" : "置顶失败")
        case let action as FeedDetailActions.FadeTopicDone:
            if action.success {
                state.model.fadeStr = nil // Disable fade button after success
            }
            Toast.show(action.success ? "下沉成功" : "下沉失败")
        case let action as FeedDetailActions.ThankReplyDone:
            if action.success {
                // Find and update the reply item
                if let index = state.model.replyInfo.items.firstIndex(where: { $0.replyId == action.replyId }) {
                    state.model.replyInfo.items[index].hadThanked = true
                    // Increment love count (handle empty string case)
                    let currentLove = state.model.replyInfo.items[index].love
                    if currentLove.isEmpty {
                        state.model.replyInfo.items[index].love = "1"
                    } else {
                        state.model.replyInfo.items[index].love = "\(currentLove.int + 1)"
                    }
                }
                Toast.show("感谢已发送")
            } else {
                Toast.show("感谢发送失败")
            }
        case let action as FeedDetailActions.ReplyToUser:
            state.replyContent = "@\(action.userName) "
            state.shouldFocusReply = true
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
