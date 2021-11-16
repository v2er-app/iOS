//
//  FeedDetailState.swift
//  FeedDetailState
//
//  Created by ghui on 2021/9/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

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
}

typealias FeedDetailStates=[String : FeedDetailState]
