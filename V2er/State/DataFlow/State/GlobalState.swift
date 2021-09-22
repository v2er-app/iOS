//
//  GlobalState.swift
//  GlobalState
//
//  Created by ghui on 2021/9/12.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct GlobalState: FluxState {
    var statusBarState = StatusBarConfigurator()
    var selectedTab: TabId = .feed
    var lastSelectedTab: TabId = .none
    var scrollTop: TabId = .none
}
