//
//  GlobalActions.swift
//  V2er
//
//  Created by ghui on 2021/9/22.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

private let R: Reducer = .global

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

struct TabbarClickAction: Action {
    var target: Reducer = R

    let selectedTab: TabId
}
