//
//  Action.swift
//  Action
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
// Actions which lead to state mutations
//

import Foundation

protocol Action {
    var id: String { get }
    var target: Reducer { get }
}

extension Action {
    var id: String {
        .default
    }
}

protocol Executable {}

protocol AsyncAction: Action, Executable {
    func execute(in store: Store)
}

protocol AwaitAction: Action, Executable {
    func execute(in store: Store) async
}

enum Reducer {
    case global
    case feed
    case feeddetail
    case explore
    case message
    case me
    case userdetail
    case tagdetail
    case login
}
