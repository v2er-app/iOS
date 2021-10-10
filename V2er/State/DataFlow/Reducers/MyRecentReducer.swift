//
//  MyRecentReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func myRecentStateReducer(_ state: MyRecentState, _ action: Action) -> (MyRecentState, Action?) {
    var state = state

    switch action {
        case let action as MyRecentActions.LoadDataStart:
            guard !state.loading else { break }
            state.loading = true
        case let action as MyRecentActions.LoadDataDone:
            state.loading = false
        case let action as MyRecentActions.RecordAction:
            break
        default:
            break
    }
    return (MyRecentState(), nil)
}

struct MyRecentActions {
    static let R: Reducer = .myrecent

    struct LoadDataStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {

        }
    }

    struct LoadDataDone: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {

        }
    }

    struct FetchDataDone: Action {
        var target: Reducer = R

    }

    struct RecordAction: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {

        }
    }

}
