//
//  UserFeedState.swift
//  V2er
//
//  Created by ghui on 2021/10/5.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

typealias UserFeedStates=[String : UserFeedState]

struct UserFeedState: FluxState {
    var hasLoadedOnce = false
    var updatableState = UpdatableState()
    var model = UserFeedInfo()
}

struct UserFeedInfo: BaseModel {
    var totalPage: Int = 0
    var items: [Item] = []

    struct Item: HtmlItemModel {
        var id: String = .default
        var title: String = .default
        var userName: String = .default
        var tag: String = .default
        var tagId: String = .default
        var replyUpdate: String = .default
        var replyNum: String = 0.string

        init(from html: Element?) {
            guard let root = html else { return }
            id = parseFeedId(root.pick("a.topic-link", .href))
            title = root.pick("span.item_title")
            userName = root.pick("span.small.fade strong a")
            tag = root.pick("a.node")
            tagId = root.pick("a.node", .href)
                .segment(separatedBy: "/")
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
            replyNum = root.pick("a.count_orange", default: 0.string)
        }

    }

    init() {}
    init(from html: Element?) {
        guard let root = html else { return }
        totalPage = root.pick("div.inner strong.fade")
            .segment(separatedBy: "/").int
        let es = root.pickAll("div.content div.cell.item")
        for e in es {
            let item = Item(from: e)
            items.append(item)
        }
    }

}
