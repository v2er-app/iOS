//
//  UserDetailReducer.swift
//  UserDetailReducer
//
//  Created by ghui on 2021/9/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func userDetailReducer(_ states: UserDetailStates, _ action: Action) -> (UserDetailStates, Action?) {
    guard action.id != .default else {
        fatalError("action in UserDetail must have id")
    }
    let id = action.id
    var states = states
    var state = states[id]!
    var followingAction: Action?
    switch action {
        case let action as UserDetailActions.FetchData.Start:
            guard !state.refreshing else { break }
            state.showProgressView = action.autoLoad
            state.hasLoadedOnce = true
            state.refreshing = true
        case let action as UserDetailActions.FetchData.Done:
            state.refreshing = false
            state.showProgressView = false
            if case let .success(result) = action.result {
                state.model = result!
            } else {
                // load failed
            }
        case let action as UserDetailActions.FetchData.InjectHtmlData:
            let html = action.htmlInfo
            // Merge full HTML data into API-sourced model
            state.model.isOnline = html.isOnline
            state.model.topicInfo = html.topicInfo
            state.model.replyInfo = html.replyInfo
            state.model.hasFollowed = html.hasFollowed
            state.model.followUrl = html.followUrl
            state.model.hasBlocked = html.hasBlocked
            state.model.blockUrl = html.blockUrl
            // Update desc if HTML has richer content
            if html.desc.notEmpty() && state.model.desc.isEmpty {
                state.model.desc = html.desc
            }
        case let action as OnAppearChangeAction:
            // FIXME: consider multi instances
            if action.isAppear {
                state.refCounts += 1
            } else {
                state.refCounts -= 1
            }
        case let action as InstanceDestoryAction:
            if state.refCounts == 0 {
                state.reseted = true
            }
        case let action as UserDetailActions.FollowDone:
            if case let .success(result) = action.result {
                state.model = result!
                Toast.show(action.originalFollowed ? "取消成功" : "关注成功")
            } else {
                Toast.show(action.originalFollowed ? "取消失败" : "关注失败")
            }
        case let action as UserDetailActions.BlockUserDone:
            if case let .success(result) = action.result {
                state.model = result!
                Toast.show(action.originalBlocked ? "取消成功" : "屏蔽成功")
            } else {
                Toast.show(action.originalBlocked ? "取消失败" : "屏蔽失败")
            }
            break
        default:
            break
    }
    if state.reseted {
        states.removeValue(forKey: id)
    } else {
        states[id] = state
    }
    return (states, followingAction)
}
