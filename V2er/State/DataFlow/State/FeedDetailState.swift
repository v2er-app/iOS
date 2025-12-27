//
//  FeedDetailState.swift
//  FeedDetailState
//
//  Created by ghui on 2021/9/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

enum ReplySortType: String, CaseIterable {
    case byTime = "time"      // 按时间排序（默认，即楼层顺序）
    case byPopularity = "popularity"  // 按热门排序（点赞数）

    var displayName: String {
        switch self {
        case .byTime: return "时间"
        case .byPopularity: return "热门"
        }
    }

    var iconName: String {
        switch self {
        case .byTime: return "clock"
        case .byPopularity: return "flame"
        }
    }
}

struct FeedDetailState: FluxState {
    var refCounts = 0
    var reseted: Bool = false
    var hasLoadedOnce = false
    var showProgressView: Bool = false
    var refreshing = false
    var loadingMore = false
    var willLoadPage = 0
    var hasMoreData = true
    var model: FeedDetailInfo = FeedDetailInfo()
    var ignored: Bool = false
    var replyContent: String = .empty
    var replySortType: ReplySortType = .byTime
    var shouldFocusReply: Bool = false
}

typealias FeedDetailStates=[String : FeedDetailState]
