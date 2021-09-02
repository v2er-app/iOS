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
        let id = UUID()
        let feedId: String

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
        let tagLink: String
        // @Pick("a[class^=count_]")
        let replies: Int
    }

    init() {}

    init(from htmlDoc: Document) {
        guard let root = htmlDoc.pickOne("div#Wrapper") else {
            return;
        }
        unReadNums = root.pick("input.super.special.button", .value)
        twoStepStr = root.pick("form[action=/2fa]")
        let elements = root.pickAll("div.cell.item")
        for e in elements {
            let feedId = ""
            let title = e.pick("span.item_title > a")
            let linkPath = e.pick("span.item_title > a", .href)
            let avatar = e.pick("td > a > img", .src)
            let userName = e.pick("span.small.fade > strong > a")
            let time = e.pick("span.small.fade", at: 1, .text)
            let tagName = e.pick("span.small.fade > a")
            let tagLink = e.pick("span.small.fade > a", .href)
            let replies = e.pick("a[class^=count_]").toInt()

            let item = Item(feedId: feedId, title: title,
                            linkPath: linkPath, avatar: avatar,
                            userName: userName,
                            time: time, tagName: tagName,
                            tagLink: tagLink, replies: replies)
            items.append(item)
        }
//        log("FeedInfo: \(self)")
    }

}
