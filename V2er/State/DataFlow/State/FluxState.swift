//
//  BaseState.swift
//  BaseState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

enum DataSource: String {
    case apiV2 = "API v2"
    case html = "HTML"
}

public protocol FluxState{
    mutating func reset()
}

extension FluxState {
    mutating func reset() {
        
    }
}
