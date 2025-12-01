//
//  GlobalState.swift
//  GlobalState
//
//  Created by ghui on 2021/9/12.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

enum TabId: String {
    case none
    case feed, explore, message, me
}

struct GlobalState: FluxState {
    var selectedTab: TabId = .feed
    var lastSelectedTab: TabId = .none
    var scrollTopTab: TabId = .none
    var toast = Toast()
    var launchFinished: Bool = false

    static var account: AccountInfo? {
        AccountState.getAccount()
    }

    static var hasSignIn: Bool {
        AccountState.hasSignIn()
    }
}

