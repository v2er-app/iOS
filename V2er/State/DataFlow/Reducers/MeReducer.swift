//
//  MeReducer.swift
//  MeReducer
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func meStateReducer(_ state: MeState, _ action: Action) -> (MeState, Action?) {
    var state = state
    var followingAction: Action?

    switch action {
        case let action as MeActions.FetchBalance.Done:
            if case .success(let balanceInfo) = action.result {
                if let balance = balanceInfo {
                    AccountState.updateBalance(balance)
                    log("Balance updated: gold=\(balance.gold), silver=\(balance.silver), bronze=\(balance.bronze)")
                } else {
                    log("Balance info is nil")
                }
            } else if case .failure(let error) = action.result {
                log("Failed to fetch balance: \(error)")
            }
        default:
            break
    }
    return (state, followingAction)
}
