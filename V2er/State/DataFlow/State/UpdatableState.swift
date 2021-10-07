//
//  UpdatableState.swift
//  V2er
//
//  Created by ghui on 2021/9/30.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

public struct UpdatableState {
    var refreshing = false
    var loadingMore = false
    var hasLoadedOnce = false
    var willLoadPage = 0
    var hasMoreData = true
    var showLoadingView = false
    var scrollToTop: Int = 0
}
