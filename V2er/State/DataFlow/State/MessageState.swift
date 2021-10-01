//
//  MessageState.swift
//  MessageState
//
//  Created by ghui on 2021/8/9.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct MessageState: FluxState {
    var hasLoadedOnce = false
    var updatableState: UpdatableState = UpdatableState()
    var model = MessageInfo()
}

struct MessageInfo: BaseModel {
    var totalPage: Int = 0
    var items: [Item] = []

    struct Item: HtmlItemModel {
        let id = UUID()
        var name: String = .default
        var avatar: String = .default
        var title: String = .default
        var link: String = .default
        var content: String = .default
        var time: String = .default

        init(from html: Element?) {
            guard let root = html else { return }
            name = root.pick("a[href^=/member/] strong")
            avatar = parseAvatar(root.pick("a[href^=/member/] img", .src))
            title = root.pick("span.fade")
            link = root.pick("a[href^=/t/]", .href)
            content = root.pick("div.payload", .innerHtml)
            time = root.pick("span.snow")
        }
    }

    init() {}
    init(from html: Element?) {
        guard let root = html else { return }
        let lastNormalpage = root.pick("div.box a.page_normal", at: .last).toInt()
        let currentPage = root.pick("div.box a.page_current").toInt()
        totalPage = max(lastNormalpage, currentPage)
        let elements = root.pickAll("div.cell[id^=n_]")
        for e in elements {
            let item = Item(from: e)
            items.append(item)
        }
        log("items.count: \(items.count)")
    }

}
