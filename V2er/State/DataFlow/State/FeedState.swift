//
//  FeedState.swift
//  FeedState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct FeedState: FluxState {
    var loading: Bool = false
    var newsInfo: NewsListInfo?
}
