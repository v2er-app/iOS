//
//  Actions.swift
//  General Actions
//
//  Created by ghui on 2021/9/12.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct OnAppearChangeAction: Action {
    var target: Reducer
    var id: String
    var isAppear: Bool
}

struct InstanceDestoryAction: Action {
    var target: Reducer
    var id: String
}

protocol InstanceIdentifiable {
    var instanceId: String {
        get
    }
}
