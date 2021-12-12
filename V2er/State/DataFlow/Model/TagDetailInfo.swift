//
//  TagDetailInfo.swift
//  TagDetailInfo
//
//  Created by ghui on 2021/9/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

// div#Main
struct TagDetailInfo: BaseModel {
    var rawData: String?
    // onclick="location.href = '/new/career';
    // div.title div.node-breadcrumb, ›
    var tagName: String = .default
    // div.cell.page-content-header div.intro
    var tagDesc: String = .default
    // div.cell.page-content-header img, alt=tagid
    var tagId: String = .default
    // div.cell.page-content-header img
    var tagImage: String = .default
    // div.cell.flex-one-row div:not(div#money)
    var countOfStaredPeople: String = .default
    // span.topic-count strong
    var topicsCount: String = .default
    var totalPage: Int = 0
    // a[href*=favorite/], .href
    var starLink: String = .default
    var hasStared: Bool = false
    // div.box div.cell:has(table)
    var topics: [Item] = []

    func isValid() -> Bool {
        topics.count == 0 || topics[0].userName.notEmpty()
    }

    struct Item: HtmlItemModel {
        // span.item_title a
        var id: String = .default
        // img.avatar, .src
        var avatar: String = .default
        // span.item_title
        var title: String = .default
        // span.small.fade strong
        var userName: String = .default
        var replyCount: String = .default
        var timeAndReplier: String = .default

        init() {}
        init(from html: Element?) {
            guard let root = html else { return }
            id = parseFeedId(root.pick("span.item_title a", .href))
            avatar = root.pick("img.avatar", .src)
            title = root.pick("span.item_title")
            userName = root.pick("span.topic_info strong a", at: .first)
            replyCount = root.pick("a.count_livid")
            timeAndReplier = root.pick("span.topic_info")
                .segment(from: "•")
                .trim()
        }
    }

    init() {}
    init(from html: Element?) {
        guard let root = html else { return }
        tagName = root.pick("div.title div.node-breadcrumb")
            .segment(separatedBy: "›")
        tagDesc = root.pick("div.cell.page-content-header div.intro")
        let imgNode = root.pickOne("div.cell.page-content-header img")
        tagId = imgNode?.value(.alt) ?? .default
        tagImage = imgNode?.value(.src) ?? .default
        countOfStaredPeople = root.pick("div.cell.flex-one-row div:not(div#money)")
            .segment(separatedBy: " ", at: .first)
        topicsCount = root.pick("span.topic-count strong")
        let lastNormalpage = root.pick("div.box a.page_normal", at: .last).int
        let currentPage = root.pick("div.box span.page_current").int
        totalPage = max(lastNormalpage, currentPage)
        let favoritePath = root.pick("a[href*=/favorite/]", .href)
        starLink = APIService.baseUrlString.appending(favoritePath)
        hasStared = starLink.notEmpty() && starLink.contains("/unfavorite/")

        let elements = root.pickAll("div#TopicsNode div.cell:has(table)")
        for e in elements {
            let item = Item(from: e)
            topics.append(item)
        }
    }

}
