//
//  TagDetailState.swift
//  TagDetailState
//
//  Created by ghui on 2021/9/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct TagDetailState: FluxState {
    var refCounts = 0
    var reseted: Bool = false
    var hasLoadedOnce = false
    var showProgressView: Bool = true
    var loadingMore = false
    var willLoadPage = 1
    var hasMoreData = true
    var model: TagDetailInfo = TagDetailInfo()
}

typealias TagDetailStates = [String : TagDetailState]
