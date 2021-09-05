//
//  Action.swift
//  Action
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
// Actions which lead to state mutations
//

import Foundation

protocol Action {}

protocol Executable { }

protocol AsyncAction: Action, Executable {
    func execute(in store: Store)
}

protocol AwaitAction: Action, Executable {
    func execute(in store: Store) async
}
