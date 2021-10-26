//
//  AppState.swift
//  AppState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct AppState: FluxState {
    var globalState = GlobalState()
    var loginState = LoginState()
    var feedState = FeedState()
    var feedDetailStates: FeedDetailStates = [:]
    var exploreState = ExploreState()
    var messageState = MessageState()
    var meState = MeState()
    var userDetailStates: UserDetailStates = [:]
    var tagDetailStates: TagDetailStates = [:]
    var userFeedStates: UserFeedStates = [:]
    var myFavoriteState = MyFavoriteState()
    var myFollowState = MyFollowState()
    var myRecentState = MyRecentState()
    var settingState = SettingState()
    var createTopicState = CreateTopicState()
    var searchState = SearchState()
}
