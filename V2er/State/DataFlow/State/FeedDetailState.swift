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
    var refreshing: Bool = false
    var loadingMore: Bool = false
    var willLoadPage: Int = 0
    var hasMoreData: Bool = false
    var detailInfo: FeedDetailInfo = FeedDetailInfo()
}

typealias FeedDetailStates=[String : FeedDetailState]
