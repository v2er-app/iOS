//
//  FeedReducer.swift
//  FeedReducer
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func feedStateReducer(_ state: FeedState, _ action: Action) -> (FeedState, Action?) {
    var state = state
    var followingAction: Action?
    switch action {
        case let action as FeedActions.FetchData.Start:
            guard !state.refreshing else { break }
            state.showProgressView = action.autoLoad
            state.hasLoadedOnce = true
            state.refreshing = true
        case let action as FeedActions.FetchData.Done:
            state.refreshing = false
            state.showProgressView = false
            if case let .success(newsInfo) = action.result {
                state.feedInfo = newsInfo ?? FeedInfo()
                state.willLoadPage = 1
            } else { }
        case let action as FeedActions.LoadMore.Start:
            guard !state.refreshing else { break }
            guard !state.loadingMore else { break }
            state.loadingMore = true
            break
        case let action as FeedActions.LoadMore.Done:
            state.loadingMore = false
            state.hasMoreData = true // todo check vary tabs
            if case let .success(newsInfo) = action.result {
                state.willLoadPage += 1
                state.feedInfo.append(feedInfo: newsInfo!)
            } else {
                // failed
            }
        case let action as FeedActions.ClearMsgBadge:
            state.feedInfo.unReadNums = 0
        default:
            break
    }
    return (state, followingAction)
}


struct FeedActions {
    static let reducer: Reducer = .feed

    struct FetchData {
        struct Start: AwaitAction {
            var target: Reducer = reducer
            let tab: Tab = .all
            var page: Int = 0
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<FeedInfo> = await APIService.shared
                    .htmlGet(endpoint: .tab, ["tab": tab.rawValue])
                dispatch(FetchData.Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = reducer

            let result: APIResult<FeedInfo>
        }
    }

    struct LoadMore {
        struct Start: AwaitAction {
            var target: Reducer = reducer
            var willLoadPage: Int = 1

            init(_ willLoadPage: Int) {
                self.willLoadPage = willLoadPage
            }

            func execute(in store: Store) async {
                let endpoint: Endpoint = willLoadPage >= 1 ? .recent : .tab
                let result: APIResult<FeedInfo> = await APIService.shared
                    .htmlGet(endpoint: endpoint, ["p": willLoadPage.string])
                dispatch(FeedActions.LoadMore.Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = reducer
            let result: APIResult<FeedInfo>
        }
    }

    struct ClearMsgBadge: Action {
        var target: Reducer = reducer
    }

}
