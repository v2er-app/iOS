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

    func dispatch(_ action: Action) {
        DispatchQueue.main.async { [self] in
            log("====> dispatch action: \(action)")
            let result = self.reduce(initialState: self.appState, action: action)
            appState = result.0
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
        (appState.feedState, followingAction) = feedStateReducer(appState.feedState, action)
        (appState.exploreState, followingAction) = exploreStateReducer(appState.exploreState, action)
//        (appState.messageState) = messageStateReducer(appState.messageState, action)
//        (appState.meState) = meStateReducer(appState.meState, action)
        return (appState, followingAction)
    }

}

func dispatch(action: Action) {
    Store.shared.dispatch(action)
}

func run(action: AwaitAction) async {
    await action.execute(in: Store.shared)
}
