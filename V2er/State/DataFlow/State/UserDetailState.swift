//
//  UserDetailState.swift
//  UserDetailState
//
//  Created by ghui on 2021/9/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct UserDetailState: FluxState {
    var refCounts = 0
    var reseted = false
    var refreshing = false
    var hasLoadedOnce = false
    var showProgressView = false
    var model = UserDetailInfo()
}

typealias UserDetailStates=[String : UserDetailState]
