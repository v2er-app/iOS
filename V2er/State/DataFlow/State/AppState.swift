//
//  AppState.swift
//  AppState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct AppState: FluxState {
    var feedState = FeedState()
//    var feedDetailState = FeedDetailState()
    var feedDetailStates: FeedDetailStates = [:]
    var exploreState = ExploreState()
    var messageState = MessageState()
    var meState = MeState()
    var mainPageState = MainPageState()
}
