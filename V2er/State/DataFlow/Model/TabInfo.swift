//
//  TabInfo.swift
//  TabInfo
//
//  Created by ghui on 2021/8/21.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

enum Tab: String {
    case all
    case tech
    case creative
    case play
    case apple
    case jobs
    case deals
    case city
    case qna
    case hot
    case r2
    case nodes
    case members

    func displayName() -> String {
        var name: String? = nil
        switch(self) {
            case .all:
                name = "全部"
            case .tech:
                name = "技术"
            case .creative:
                name = "创意"
            case .play:
                name = "好玩"
            case .apple:
                name = "Apple"
            case .jobs:
                name = "酷工作"
            case .deals:
                name = "交易"
            case .city:
                name = "城市"
            case .qna:
                name = "问与答"
            case .hot:
                name = "最热"
            case .r2:
                name = "r2"
            case .nodes:
                name = "节点"
            case .members:
                name = "关注"
        }
        assert(name != nil , "Tab display name shouldn't be null")
        return ""
    }
}
