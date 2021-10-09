//
//  MyFollowState.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct MyFollowState: FluxState {
    var updatableState = UpdatableState()
    var model: MyFollowInfo? = nil
}

struct MyFollowInfo: BaseModel {
    var totalPage: Int = 0
    var items: [Item] = []

    struct Item: FeedItemInfo {
        var id: String = .default
        var avatar: String?
        var userName: String?
        var replyUpdate: String?
        var title: String?
        var replyNum: String? = 0.string
        var tagName: String?
        var tagId: String?

        init(id: String) {
            self.id = id
        }

        init?(from html: Element?) {
            guard let root = html else { return nil }
            id = parseFeedId(root.pick("span.item_title a[href^=/t/]", .href))
            avatar = root.pick("img.avatar", .src)
            userName = root.pick("strong a[href^=/member/]")
            title = root.pick("span.item_title a[href^=/t/]")
            replyNum = root.pick("a[class^=count_]")
            tagName = root.pick("a.node")
            tagId = root.pick("a.node", .href)
                .segment(separatedBy: "/")
            let timeReplier = root.pick("span.topic_info")
            replyUpdate = timeReplier.segment(separatedBy: "•", at: 2)
            let replier = timeReplier.segment(separatedBy: "•", at: 3)
                .segment(separatedBy: " ")
            replyUpdate!.append("\(replier) 回复了")
        }
    }

    init?(from html: Element?) {
        guard let root = html?.pickOne("div#Wrapper") else { return nil }
        totalPage = root.pick("div.inner strong.fade")
            .segment(separatedBy: "/").int
        let es = root.pickAll("div.cell.item")
        for e in es {
            guard let item = Item(from: e) else { continue }
            items.append(item)
        }
    }
}
