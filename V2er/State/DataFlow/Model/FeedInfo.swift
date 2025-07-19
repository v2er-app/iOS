//
//  NewsListInfo.swift
//  NewsListInfo
//
//  Created by ghui on 2021/8/16.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup
import CloudKit

// @Pick("div#Wrapper")
struct FeedInfo: BaseModel {
    var rawData: String?

    // @Pick(value = "input.super.special.button", attr = "value")
    var unReadNums: Int = 0
    // @Pick("form[action=/2fa]")
    var twoStepStr: String = .empty
    // @Pick("div.cell.item")
    var items: [Item] = []

    func isValid() -> Bool {
        if twoStepStr.notEmpty() && twoStepStr.contains("两步验证") {
            return false
        }
        return items.count > 0 || items[0].userName.notEmpty
    }

    mutating func append(feedInfo: FeedInfo) {
        self.unReadNums = feedInfo.unReadNums
        self.twoStepStr = feedInfo.twoStepStr
//        self.items.append(contentsOf: feedInfo.items)

        // merge update
        var dict: [String: Int] = [:]
        self.items.enumerated().forEach { (index, value) in
            dict[value.id] = index
        }
        for e in feedInfo.items {
            if dict.keys.contains(e.id) {
                if let index = dict[e.id] {
                    self.items[index] = e
                }
            } else {
                self.items.append(e)
            }
        }
    }

    struct Item: FeedItemProtocol, HtmlItemModel {
        var id: String
        // @Pick(value = "span.item_title > a")
        var title: String?
        // @Pick(value = "td > a > img", attr = "src")
        var avatar: String?
        // @Pick(value = "span.small.fade > strong > a")
        var userName: String?
        // @Pick(value = "span.small.fade:last-child", attr = "ownText")
        var replyUpdate: String?
        // @Pick(value = "span.small.fade > a")
        var nodeName: String?
        // @Pick(value = "span.small.fade > a", attr = "href")
        var nodeId: String?
        // @Pick("a[class^=count_]")
        var replyNum: String?

//        static func == (lhs: Self, rhs: Self) -> Bool {
//            lhs.id == rhs.id &&
//            lhs.replyNum == rhs.replyNum
//        }
//
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//            hasher.combine(replyNum)
//        }

        init(id: String, title: String? = nil, avatar: String? = nil) {
            self.id = id
            self.title = title
            self.avatar = avatar
        }

        init(id: String, title: String? = .default, avatar: String?,
             userName: String?, replyUpdate: String?, nodeName: String?,
             nodeId: String?, replyNum: String?) {
            self.id = id
            self.title = title
            self.avatar = avatar
            self.userName = userName
            self.replyUpdate = replyUpdate
            self.nodeName = nodeName
            self.nodeId = nodeId
            self.replyNum = replyNum
        }

        init?(from html: Element?) {
            guard let root = html else { return nil }
            id = parseFeedId(root.pick("span.item_title > a", .href))
            title = root.pick("span.item_title > a")
            avatar = parseAvatar(root.pick("td > a > img", .src))
            userName = root.pick("span.small.fade > strong > a")
            let timeReplier = root.pick("span.small.fade", at: 1, .text)
            if timeReplier.contains("来自") {
                let time = timeReplier.segment(separatedBy: "•", at: .first)
                    .trim()
                let replier = timeReplier.segment(separatedBy: "来自").trim()
                replyUpdate = time.appending(" \(replier) ")
                    .appending("回复了")
            } else {
                replyUpdate = timeReplier
            }
            nodeName = root.pick("span.small.fade > a")
            nodeId = root.pick("span.small.fade > a", .href)
                .segment(separatedBy: "/")
            replyNum = root.pick("a[class^=count_]")
        }
    }

    init() {}

    init(from html: Element?) {
        guard let root = html?.pickOne("div#Wrapper") else { return }
        let unReadString = root.pick("input.super.special.button", .value)
        if unReadString.isEmpty {
            unReadNums = 0
        } else {
            unReadNums = unReadString.segment(separatedBy: " ", at: .first).int
        }
        twoStepStr = root.pick("form[action=/2fa]")
        let elements = root.pickAll("div.cell.item")
        for e in elements {
            if let item = Item(from: e) {
                items.append(item)
            }
        }
        log("FeedInfo: \(self)")
    }

}

// MARK: - Mock Data for UI Testing
extension FeedInfo {
    static func mockData() -> FeedInfo {
        var feedInfo = FeedInfo()
        feedInfo.items = [
            Item(id: "mock1",
                 title: "深色模式下的文字对比度优化讨论",
                 avatar: "https://cdn.v2ex.com/avatar/2c60/19e1/1_mini.png",
                 userName: "testuser1",
                 replyUpdate: "12分钟前",
                 nodeName: "分享创造",
                 nodeId: "create",
                 replyNum: "42"),
            
            Item(id: "mock2",
                 title: "SwiftUI 中实现自适应颜色系统的最佳实践，如何在保证视觉美观的同时确保可访问性",
                 avatar: "https://cdn.v2ex.com/avatar/c4ca/4238/2_mini.png",
                 userName: "swiftdev",
                 replyUpdate: "25分钟前 designer 回复了",
                 nodeName: "程序员",
                 nodeId: "programmer",
                 replyNum: "128"),
            
            Item(id: "mock3",
                 title: "iOS 15 新特性：Dynamic Color 深度解析",
                 avatar: "https://cdn.v2ex.com/avatar/9b1b/00d4/3_mini.png",
                 userName: "iosdev",
                 replyUpdate: "1小时前",
                 nodeName: "iPhone",
                 nodeId: "iphone",
                 replyNum: "15"),
            
            Item(id: "mock4",
                 title: "关于 V2EX 客户端的一些改进建议",
                 avatar: "https://cdn.v2ex.com/avatar/e3db/1115/4_mini.png",
                 userName: "feedback",
                 replyUpdate: "2小时前",
                 nodeName: "反馈",
                 nodeId: "feedback",
                 replyNum: "8"),
            
            Item(id: "mock5",
                 title: "使用 Color.dynamic 实现深浅模式自动切换，支持 iOS 15+ 的高对比度模式",
                 avatar: "https://cdn.v2ex.com/avatar/fa5e/4216/5_mini.png",
                 userName: "uiexpert",
                 replyUpdate: "3小时前 learner 回复了",
                 nodeName: "设计",
                 nodeId: "design",
                 replyNum: "67"),
            
            Item(id: "mock6",
                 title: "征集：你觉得哪些 App 的深色模式做得最好？",
                 avatar: "https://cdn.v2ex.com/avatar/1b2c/3317/6_mini.png",
                 userName: "survey",
                 replyUpdate: "5小时前",
                 nodeName: "问与答",
                 nodeId: "qna",
                 replyNum: "234"),
            
            Item(id: "mock7",
                 title: "Text 和 Background 颜色搭配的无障碍设计原则",
                 avatar: "https://cdn.v2ex.com/avatar/7d8e/4418/7_mini.png",
                 userName: "a11y",
                 replyUpdate: "6小时前",
                 nodeName: "分享发现",
                 nodeId: "share",
                 replyNum: "19"),
            
            Item(id: "mock8",
                 title: "Swift Package Manager 管理颜色资源的技巧分享，如何构建跨项目的设计系统",
                 avatar: "https://cdn.v2ex.com/avatar/8e9f/5519/8_mini.png",
                 userName: "swiftpm",
                 replyUpdate: "8小时前 packager 回复了",
                 nodeName: "macOS",
                 nodeId: "macos",
                 replyNum: "45"),
            
            Item(id: "mock9",
                 title: "讨论：App Store 应该强制要求应用支持深色模式吗？",
                 avatar: "https://cdn.v2ex.com/avatar/9fa0/6620/9_mini.png",
                 userName: "appstore",
                 replyUpdate: "10小时前",
                 nodeName: "Apple",
                 nodeId: "apple",
                 replyNum: "156"),
            
            Item(id: "mock10",
                 title: "分享一个 SwiftUI Color Extension，让颜色管理更简单",
                 avatar: "https://cdn.v2ex.com/avatar/0ab1/7721/10_mini.png",
                 userName: "coder",
                 replyUpdate: "12小时前",
                 nodeName: "分享创造",
                 nodeId: "create",
                 replyNum: "88")
        ]
        return feedInfo
    }
}
