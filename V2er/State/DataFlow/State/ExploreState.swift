//
//  ExploreState.swift
//  ExploreState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct ExploreState: FluxState {
    var showProgressView: Bool = false
    var hasLoadedOnce = false
    var refreshing: Bool = false
    var exploreInfo: ExploreInfo = ExploreInfo()
}
