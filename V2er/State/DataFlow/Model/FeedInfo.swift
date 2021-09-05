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
        let id: String
        // @Pick(value = "span.item_title > a")
        let title: String
        // @Pick(value = "span.item_title > a", attr = "href")
        let linkPath: String
        // @Pick(value = "td > a > img", attr = "src")
        let avatar: String
        // @Pick(value = "span.small.fade > strong > a")
        let userName: String
        // @Pick(value = "span.small.fade:last-child", attr = "ownText")
        let time: String
        // @Pick(value = "span.small.fade > a")
        let tagName: String
        // @Pick(value = "span.small.fade > a", attr = "href")
        let tagId: String
        // @Pick("a[class^=count_]")
        let replies: Int
    }

    init() {}

    init(from html: Element?) {
        guard let root = html?.pickOne("div#Wrapper") else { return }
        unReadNums = root.pick("input.super.special.button", .value)
        twoStepStr = root.pick("form[action=/2fa]")
        let elements = root.pickAll("div.cell.item")
        for e in elements {
            let id = e.pick("span.item_title > a", .href)
                .remove("/t/")
                .segment(separatedBy: "#", at: .first)
            let title = e.pick("span.item_title > a")
            let linkPath = e.pick("span.item_title > a", .href)
            let avatar = e.pick("td > a > img", .src)
            let userName = e.pick("span.small.fade > strong > a")
            let time = e.pick("span.small.fade", at: 1, .text)
            let tagName = e.pick("span.small.fade > a")
            let tagId = e.pick("span.small.fade > a", .href)
                .segment(separatedBy: "/")
            let replies = e.pick("a[class^=count_]").toInt()

            let item = Item(id: id, title: title,
                            linkPath: linkPath, avatar: avatar,
                            userName: userName,
                            time: time, tagName: tagName,
                            tagId: tagId, replies: replies)
            items.append(item)
        }
//        log("FeedInfo: \(self)")
    }

}
