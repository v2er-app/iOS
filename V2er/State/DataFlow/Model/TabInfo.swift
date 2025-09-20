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
        switch(self) {
            case .all:
                return "全部"
            case .tech:
                return "技术"
            case .creative:
                return "创意"
            case .play:
                return "好玩"
            case .apple:
                return "Apple"
            case .jobs:
                return "酷工作"
            case .deals:
                return "交易"
            case .city:
                return "城市"
            case .qna:
                return "问与答"
            case .hot:
                return "最热"
            case .r2:
                return "r2"
            case .nodes:
                return "节点"
            case .members:
                return "关注"
        }
    }
}
