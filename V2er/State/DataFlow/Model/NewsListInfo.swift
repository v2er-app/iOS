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
struct NewsListInfo: HtmlParsable {
    // @Pick(value = "input.super.special.button", attr = "value")
    let unReadNums: String?
    // @Pick("form[action=/2fa]")
    let twoStepStr: String?
    // @Pick("div.cell.item")
    var items: [Item]?

    struct Item {
        let id: String?
        // @Pick(value = "span.item_title > a")
        let title: String?
        // @Pick(value = "span.item_title > a", attr = "href")
        let linkPath: String?
        // @Pick(value = "td > a > img", attr = "src")
        let avatar: String?
        // @Pick(value = "td > a", attr = "href")
        let avatarLink: String?
        // @Pick(value = "span.small.fade > strong > a")
        let userName: String?
        // @Pick(value = "span.small.fade:last-child", attr = "ownText")
        let time: String?
        // @Pick(value = "span.small.fade > a")
        let tagName: String?
        // @Pick(value = "span.small.fade > a", attr = "href")
        let tagLink: String?
        // @Pick("a[class^=count_]")
        let replies: Int?
    }

    init?(from htmlDoc: Document) {
        guard let root = htmlDoc.pickOne("div#Wrapper") else {
            preconditionFailure("Error in Parse html doc")
            return nil
        }
        unReadNums = root.pick("input.super.special.button", .value)
        twoStepStr = root.pick("form[action=/2fa]")
        let elements = root.pickAll("div.cell.item")
        guard let elements = elements else {
            return
        }
        items = []
        for e in elements {
            let id = ""
            let title = e.pick("span.item_title > a", .href)
            let linkPath = e.pick("td > a > img", .src)
            let avatar = e.pick("td > a > img", .src)
            let avatarLink = e.pick("td > a", .href)
            let userName = e.pick("span.small.fade:last-child", .ownText)
            let time = e.pick("span.small.fade:last-child")
            let tagName = e.pick("span.small.fade > a")
            let tagLink = e.pick("span.small.fade > a", .href)
            let replies = e.pick("a[class^=count_]").toInt()

            let item = Item(id: id, title: title,
                            linkPath: linkPath, avatar: avatar,
                            avatarLink: avatarLink, userName: userName,
                            time: time, tagName: tagName,
                            tagLink: tagLink, replies: replies)
            items!.append(item)
        }

    }

}
