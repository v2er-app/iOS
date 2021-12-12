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
