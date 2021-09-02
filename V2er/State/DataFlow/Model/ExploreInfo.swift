//
//  ExploreInfo.swift
//  ExploreInfo
//
//  Created by ghui on 2021/9/1.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct ExploreInfo: BaseModel {
    // div#Bottom div.inner strong -> 关于 · 帮助文档 · FAQ · API · 我们的愿景 · 广告投放 · 感谢 · 实用小工具 · 2408 人在线
    var onlineNum: Int = 0
    // div#TopicsHot.box table
    var dailyHotInfo: [DailyHotItem] = []
    // div#Rightbar div.box div.cell a.item_node
    var hottestNodeInfo: [Node] = []
    // div#Rightbar div.box div.inner a.item_node
    var recentNodeInfo: [Node] = []
    // div.box:last-child div > table
    var nodeNavInfo: [NodeNavItem] = []

    struct DailyHotItem: Identifiable {
        // span.item_hot_topic_title a[href^=/t/] .href
        var id: String
        // a[href^=/member] .href
        var member: String
        // a[href^=/member] img .src
        var avatar: String
        // span.item_hot_topic_title .text
        var title: String
    }

    struct NodeNavItem: Identifiable, Hashable {
        var id: String {
            get { self.category }
        }
        // span.fade
        var category: String
        // a
        var nodes: [Node] = []
    }

    struct Node: Identifiable, Hashable {
        let id = UUID()
        // .text
        var name: String
        // .href
        var link: String
    }

    init() {}

    init(from htmlDoc: Document) {
        guard let root = htmlDoc.pickOne("body") else {
            return;
        }
        // 1. onlineNum
        onlineNum = root.pick("div#Bottom div.inner strong")
            .segment(separatedBy: " · ")
            .segment(at: .first, separatedBy: " ")
            .toInt()
        // 2. dailyHotInfo
        let dailyHotElements = root.pickAll("div#TopicsHot.box table")
        for e in dailyHotElements {
            let avatar = e.pick("a[href^=/member] img", .src)
            let member = e.pick("a[href^=/member]", .href)
            let title = e.pick("span.item_hot_topic_title")
            let topicId = e.pick("span.item_hot_topic_title a[href^=/t/]", .href)
                .segment(separatedBy: "/")
            let dailyHotItem = DailyHotItem(id: topicId,
                                            member: member,
                                            avatar: avatar,
                                            title: title)
            self.dailyHotInfo.append(dailyHotItem)
        }
        // 3. hottestNodeInfo
        let hottestNodeElements = root.pickAll("div#Rightbar div.box div.cell a.item_node")
        for e in hottestNodeElements {
            let name = e.value()
            let link = e.value(.href)
            let node = Node(name: name, link: link)
            self.hottestNodeInfo.append(node)
        }
        // 4. recentNodeInfo
        let recentNodeElements = root.pickAll("div#Rightbar div.box div.inner a.item_node")
        for e in recentNodeElements {
            let name = e.value()
            let link = e.value(.href)
            let node = Node(name: name, link: link)
            self.recentNodeInfo.append(node)
        }
        // 5. nodeNavInfo
        let nodeNavElements = root.pickAll("div.box:last-child div > table")
        for e in nodeNavElements {
            let category = e.pick("span.fade")
            let nodeElements = e.pickAll("a")
            var nodes: [Node] = []
            for ee in nodeElements {
                let name = ee.value()
                let link = ee.value(.href)
                let node = Node(name: name, link: link)
                nodes.append(node)
            }
            let nodesNavItem = NodeNavItem(category: category,
                                           nodes: nodes)
            self.nodeNavInfo.append(nodesNavItem)
        }
    }

}
