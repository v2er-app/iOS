//
//  FeedState.swift
//  FeedState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedState: FluxState {
    var hasLoadedOnce = false
    var showProgressView: Bool = false
    var refreshing: Bool = false
    var loadingMore: Bool = false
    var willLoadPage: Int = 0
    var hasMoreData: Bool = true
    var feedInfo: FeedInfo = FeedInfo()
}
