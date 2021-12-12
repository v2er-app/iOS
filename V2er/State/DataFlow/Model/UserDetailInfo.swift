//
//  UserDetailInfo.swift
//  UserDetailInfo
//
//  Created by ghui on 2021/9/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

// div#Wrapper
struct UserDetailInfo: BaseModel {
    var rawData: String?
    // h1
    var userName: String = .default
    // img.avatar src
    var avatar: String = .default
    // td[valign=top] > span.gray
    var desc: String = .default
    // strong.online
    var isOnline: Bool = false
    var hasFollowed: Bool = false
    var followUrl: String = .default
    var hasBlocked: Bool = false
    var blockUrl: String = .default
    var topicInfo: TopicInfo = TopicInfo()
    var replyInfo: ReplyInfo = ReplyInfo()

    func isValid() -> Bool {
        userName.notEmpty()
    }

    struct TopicInfo {
        // div.box:has(div.cell_tabs) > div.cell.item
        var items: [Item] = []

        struct Item: HtmlItemModel {
            // span.item_title a, .href
            var id: String = .default
            // strong > a[href^=/member/]:first-child
            var userName: String = .default
            // a.node
            var tag: String = .default
            // a.node, .href
            var tagId: String = .default
            // span.item_title
            var title: String = .default
            // span.small.fade:last-child
            var time: String = .default
            // a[class^=count_]
            var replyNum: Int = .default

            init(from html: Element?) {
                guard let root = html else { return }
                id = parseFeedId(root.pick("span.item_title a", .href))
                userName = root.pick("strong > a[href^=/member/]:first-child")
                tag = root.pick("a.node")
                tagId = root.pick("a.node", .href)
                    .segment(separatedBy: "/")
                title = root.pick("span.item_title")
                time = root.pick("span.small.fade", at: 1)
                replyNum = root.pick("a[class^=count_]").int
            }
        }

        init() {}

        init(from html: Element?) {
            guard let elements = html?
                    .pickAll("div.box:has(div.cell_tabs) > div.cell.item")
            else { return }
            for e in elements {
                let item = Item(from: e)
                items.append(item)
            }
        }

    }

    struct ReplyInfo: BaseModel {
        var rawData: String?

        var items: [Item] = []
        struct Item: Identifiable {
            // span.gray > a, .href
            var id: String = .default
            // span.gray
            var title: String = .default
            // span.fade
            var time: String = .default
            // contentElement, INNER_HTML
            var content: String = .default
        }

        init(){}

        init(from html: Element?) {
            guard let root = html else { return }
            let dockElements = root.pickAll("div.dock_area")
            let contentElements = root.pickAll("div.reply_content")
            // combine
            for (dock, content) in zip(dockElements, contentElements) {
                var item = Item()
                item.id = parseFeedId(dock.pick("span.gray > a", .href))
                item.title = dock.pick("span.gray")
                item.time = dock.pick("span.fade")
                item.content = content.value(.innerHtml)
                    .remove("\n")
                items.append(item)
            }
        }
    }

    init() {}

    init(from html: Element?) {
        guard let root = html?.pickOne("div#Wrapper") else { return }
        userName = root.pick("h1")
        avatar = parseAvatar(root.pick("img.avatar", .src))
        desc = root.pick("td[valign=top] > span.gray")
        isOnline = root.pick("strong.online")
            .contains("ONLINE")
        let followOnClick = root.pick("div.fr input", .onclick)
        if followOnClick.notEmpty() {
            hasFollowed = followOnClick.contains("取消")
            //    if (confirm('确认要取消对 diskerjtr 的关注？')) { location.href = '/unfollow/128373?once=15154'; }
            let sIndex = followOnClick.index(of: (hasFollowed ? "/unfollow/" : "/follow/"))!
            let eIndex = followOnClick.lastIndex(of: "'")!
            followUrl = String(followOnClick[sIndex..<eIndex])
        }

        let blockOnClick = root.pick("div.fr input[value*=lock]", .onclick)
        if blockOnClick.notEmpty() {
            hasBlocked = blockOnClick.contains("unblock")
            let sIndex = blockOnClick.index(of: (hasBlocked ? "/unblock/" : "/block/"))!
            let eIndex = blockOnClick.lastIndex(of: "'")!
            blockUrl = String(blockOnClick[sIndex..<eIndex])
        }

        topicInfo = TopicInfo(from: root)
        replyInfo = ReplyInfo(from: root)
    }

}
