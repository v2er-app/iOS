//
//  NewsListInfo.swift
//  NewsListInfo
//
//  Created by ghui on 2021/8/16.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

// @Pick("div#Wrapper")
struct FeedInfo: BaseModel {
    var rawData: String?

    // @Pick(value = "input.super.special.button", attr = "value")
    var unReadNums: String?
    // @Pick("form[action=/2fa]")
    var twoStepStr: String?
    // @Pick("div.cell.item")
    var items: [Item] = []

    mutating func append(feedInfo: FeedInfo) {
        self.unReadNums = feedInfo.unReadNums
        self.twoStepStr = feedInfo.twoStepStr
        self.items.append(contentsOf: feedInfo.items)
    }

    struct Item: Identifiable {
        var id: String = .default
        // @Pick(value = "span.item_title > a")
        var title: String = .default
        // @Pick(value = "span.item_title > a", attr = "href")
        var linkPath: String = .default
        // @Pick(value = "td > a > img", attr = "src")
        var avatar: String = .default
        // @Pick(value = "span.small.fade > strong > a")
        var userName: String = .default
        // @Pick(value = "span.small.fade:last-child", attr = "ownText")
        var time: String = .default
        // @Pick(value = "span.small.fade > a")
        var tagName: String = .default
        // @Pick(value = "span.small.fade > a", attr = "href")
        var tagId: String = .default
        // @Pick("a[class^=count_]")
        var replies: Int = 0

        init() {}

        static func create(from id: String) -> Item {
            var item = Item()
            item.id = id
            return item
        }
    }

    init() {}

    init(from html: Element?) {
        guard let root = html?.pickOne("div#Wrapper") else { return }
        unReadNums = root.pick("input.super.special.button", .value)
        twoStepStr = root.pick("form[action=/2fa]")
        let elements = root.pickAll("div.cell.item")
        for e in elements {
            var item = Item()
            item.id = parseFeedId(e.pick("span.item_title > a", .href))
            item.title = e.pick("span.item_title > a")
            item.linkPath = e.pick("span.item_title > a", .href)
            item.avatar = parseAvatar(e.pick("td > a > img", .src))
            item.userName = e.pick("span.small.fade > strong > a")
            item.time = e.pick("span.small.fade", at: 1, .text)
            item.tagName = e.pick("span.small.fade > a")
            item.tagId = e.pick("span.small.fade > a", .href)
                .segment(separatedBy: "/")
            item.replies = e.pick("a[class^=count_]").toInt()
            items.append(item)
        }
        log("FeedInfo: \(self)")
    }

}
