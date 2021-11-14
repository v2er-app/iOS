//
//  Store.swift
//  Store
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
// Store objects responsible for storing the state and providing actions to mutate that state.
//

import Foundation
import SwiftUI

final public class Store: ObservableObject {
    @Published var appState = AppState()
    public static let shared = Store()

    private init() {}

    func dispatch(_ action: Action, animation: Animation?) {
        DispatchQueue.main.async { [self] in
//            log("====> dispatch action: \(action)")
            let result = self.reduce(initialState: self.appState, action: action)
            withAnimation(animation) {
                appState = result.0
            }
            if let asyncAction = result.1 as? AsyncAction {
                asyncAction.execute(in: self)
            } else if let awaitAction = result.1 as? AwaitAction {
                Task {
                    await awaitAction.execute(in: self)
                }
            }
        }
    }

    // Reducer is a function that takes current state, applies Action to the state,
    // and generates a new state
    private func reduce(initialState: AppState, action: Action) -> (AppState, Action?) {
        var appState = initialState
        var followingAction: Action?
        switch action.target {
            case .feed:
                (appState.feedState, followingAction) = feedStateReducer(appState.feedState, action)
            case .feeddetail:
                (appState.feedDetailStates, followingAction) = feedDetailStateReducer(appState.feedDetailStates, action)
            case .explore:
                (appState.exploreState, followingAction) = exploreStateReducer(appState.exploreState, action)
            case .message:
                 (appState.messageState, followingAction) = messageStateReducer(appState.messageState, action)
            case .me:
                 (appState.meState, followingAction) = meStateReducer(appState.meState, action)
            case .userdetail:
                (appState.userDetailStates, followingAction) = userDetailReducer(appState.userDetailStates, action)
            case .tagdetail:
                (appState.tagDetailStates, followingAction) = tagDetailStateReducer(appState.tagDetailStates, action)
            case .login:
                (appState.loginState, followingAction) = loginReducer(appState.loginState, action)
            case .userfeed:
                (appState.userFeedStates, followingAction) = userFeedStateReducer(appState.userFeedStates, action)
            case .myfavorite:
                (appState.myFavoriteState, followingAction) = myFavoriteStateReducer(appState.myFavoriteState, action)
            case .myfollow:
                (appState.myFollowState, followingAction) = myFollowStateReducer(appState.myFollowState, action)
            case .myrecent:
                (appState.myRecentState, followingAction) = myRecentStateReducer(appState.myRecentState, action)
            case .setting:
                (appState.settingState, followingAction) = settingStateReducer(appState.settingState, action)
            case .createfeed:
                (appState.createTopicState, followingAction) = createStateReducer(appState.createTopicState, action)
            case .search:
                (appState.searchState, followingAction) = searchStateReducer(appState.searchState, action)
                break
            case .global:
                (appState.globalState, followingAction) = globalStateReducer(appState.globalState, action)
                fallthrough
            default:
                (appState, followingAction) = defaultReducer(appState, action)
        }
        if followingAction == nil && action is Executable {
            followingAction = action
        }
        return (appState, followingAction)
    }

}

func dispatch(_ action: Action, _ animation: Animation? = nil) {
    Store.shared.dispatch(action, animation: animation)
}

func run(action: AwaitAction) async {
    await action.execute(in: Store.shared)
}
