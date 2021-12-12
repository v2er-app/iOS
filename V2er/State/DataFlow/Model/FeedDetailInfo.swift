//
//  FeedDetailInfo.swift
//  FeedDetailInfo
//
//  Created by ghui on 2021/9/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct FeedDetailInfo: BaseModel {
    var rawData: String?
    // div#Wrapper
    var headerInfo: HeaderInfo?
    // div.content div.box
    var contentInfo: ContentInfo?
    // div.problem
    var problem: ProblemInfo?
    // div[id^=r_]
    var replyInfo: ReplyInfo = ReplyInfo()
    // input[name=once] , value
    var once: String?
    // meta[property=og:url], content
    var topicId: String?
    // a[onclick*=/report/topic/], onclick
    var reportLink: String?
    // div.content div.box div.inner span.fade
    var hasReported: Bool?
    // a[onclick*=/fade/topic/], onclick
    var fadeStr: String?
    // a[onclick*=/sticky/topic/], onclick
    var stickyStr: String?

    mutating func injectId(_ id: String) {
         self.topicId = id
         self.headerInfo?.id = id
    }

    func isValid() -> Bool {
        headerInfo != nil && headerInfo!.isValid()
    }

    struct HeaderInfo: HtmlParsable, FeedItemProtocol {
        var id: String = .empty
        // div.box img.avatar, .src
        var avatar: String?
        // div.box small.gray a
        var userName: String?
        // div.box small.gray, .ownText
        var replyUpdate: String?
        // div.box a[href^=/go]
        var nodeName: String?
        // div.box a[href^=/go], .href
        var nodeId: String?
        // div.cell span.gray:contains(回复)
        var replyNum: String?
        var currentPage: Int = 1
        var totalPage: Int = 1
        // div.box h1
        var title: String?
        // div.box a[href*=favorite/], .href
        var favoriteLink: String = .empty
        var hadStared: Bool = false
        // div.box div[id=topic_thank]
        var hadThanked: Bool = false
        // div.box div.inner div#topic_thank
        var isThankable: Bool = false
        // div.box div.header a.op
        var appendText: String = .empty

        func isValid() -> Bool {
            userName.notEmpty && nodeName.notEmpty
        }

        mutating func update(_ headerInfo: HeaderInfo?) {
            guard let headerInfo = headerInfo else { return }
            let originalId = self.id
            self = headerInfo
            self.id = originalId
        }

        func toFeedItemInfo() -> FeedInfo.Item {
            return FeedInfo.Item(id: id, title: title,
                                 avatar: avatar, userName: userName,
                                 replyUpdate: replyUpdate, nodeName: nodeName,
                                 nodeId: nodeId, replyNum: replyNum)
        }

        init(id: String, title: String?, avatar: String?) {
            self.id = id
            self.title = title
            self.avatar = avatar
        }

        init?(from html: Element?) {
            guard let root = html else { return nil }
            avatar = parseAvatar(root.pick("div.box img.avatar", .src))
            userName = root.pick("div.box small.gray a")
            replyUpdate = root.pick("div.box small.gray", .ownText)
                .remove("By at")
                .replace(segs: " · ", with: " ")
            nodeName = root.pick("div.box a[href^=/go]")
            nodeId = root.pick("div.box a[href^=/go]", .href)
                .segment(separatedBy: "/")
            replyNum = root.pick("div.cell span.gray:contains(回复)")
                .segment(separatedBy: " ", at: .first)
            let lastNormalpage = root.pick("div.box a.page_normal", at: .last).int
            currentPage = root.pick("div.box span.page_current", default: "1").int
            totalPage = max(lastNormalpage, currentPage, 1)
            title = root.pick("div.box h1")
            favoriteLink = root.pick("div.box a[href*=favorite/]", .href)
            hadStared = favoriteLink.notEmpty() && favoriteLink.contains("unfavorite/")
            hadThanked = root.pick("div.box div[id=topic_thank]")
                .contains("已发送")
            isThankable = root.pick("div.box div.inner div#topic_thank")
                .notEmpty()
            appendText = root.pick("div.box div.header a.op")
        }
    }

    struct ContentInfo: HtmlParsable {
        // .html
        var html: String? = .default
        var imgs: [String] = []

        init(from doc: Element?) {
            guard let root = doc else { return }
            root.remove(selector: ".header")
                .remove(selector: ".inner")
            // For HtmlView loading
            for img in root.pickAll("img") {
                let imgUrl = try? img.attr("src") ?? .empty
                if imgUrl.isEmpty { continue }
                do {
//                    try img.attr("original_src", imgUrl!)
//                    try img.attr("src", "image_holder_loading.gif")
//                    imgs.append(imgUrl!)
                } catch {
                    log("error in inject images")
                }
            }

            if root.value() == .empty
                && !root.hasClass("embedded_video_wrapper") {
                self.html = .default
            } else {
                self.html = try? root.html()
                // append https:// to the images
                let img = "src=\"//i.v2ex.co/"
                let httpImg = "src=\"https://i.v2ex.co/"
                self.html = self.html?.replace(segs: img, with: httpImg)
            }
        }
    }

    struct ProblemInfo: HtmlParsable {
        // .ownText
        var title: String = .default
        // ul li
        var tips: [String] = []

        init(from html: Element?) {
            guard let root = html else { return }
            title = root.value(.ownText)
            let es = root.pickAll("ul li")
            for e in es {
                tips.append(e.value())
            }
        }
    }

    struct ReplyInfo {
        var items: [Item] = []
        var owner: String = .empty

        struct Item: HtmlItemModel, Hashable {
            // span.no
            var floor: Int = 0
            var id = UUID()
            // div.reply_content, .innerHtml
            var content: String = .default
            // strong a.dark[href^=/member]
            var userName: String = .default
            // img.avatar, .src
            var avatar: String = .default
            // span.fade.small:not(:contains(♥))
            var time: String = .default
            // span.small.fade:has(img)
            var love: String = .default
            // div.thank_area.thanked
            var hadThanked: Bool = false
            // id
            var replyId: String = .default
            var owner: String = .empty
            var isOwner: Bool  {
                userName == owner && owner != .empty
            }

            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.floor == rhs.floor
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(floor)
            }
            init(from html: Element?) {
                self.init(from: html, owner: .empty)
            }

            init(from html: Element?, owner: String) {
                guard let root = html else { return }
                self.owner = owner
                floor = root.pick("span.no").int
                content = root.pick("div.reply_content", .innerHtml)
                    .replace(segs: "\n", with: "")
                userName = root.pick("strong a.dark[href^=/member]")
                avatar = root.pick("img.avatar", .src)
                time = root.pick("span.fade.small:not(:contains(♥))")
                love = root.pick("span.small.fade:has(img)")
                hadThanked = root.pick("div.thank_area.thanked")
                    .notEmpty()
                replyId = root.value(.id)
            }
        }

        init() {}
        init(from elements: Elements, owner: String) {
            self.owner = owner
            for e in elements {
                let item = Item(from: e, owner: owner)
                items.append(item)
            }
        }

        mutating func append(_ replyInfo: ReplyInfo?, afterReply: Bool = false) {
            guard let replyInfo = replyInfo else { return }
            self.items.append(contentsOf: replyInfo.items)
            if afterReply {
                self.items = self.items.uniqued()
            }
        }

    }

    init() {}
    init(from html: Element?) {
        guard let root = html else { return }
        self.topicId = root.pick("meta[property=og:url]", .content)
        self.headerInfo = HeaderInfo(from: root.pickOne("div#Wrapper"))
        self.contentInfo = ContentInfo(from: root.pickOne("div.content div.box"))
        self.problem = ProblemInfo(from: root.pickOne("div.problem"))
        let owner: String = headerInfo?.userName ?? .empty
        self.replyInfo = ReplyInfo(from: root.pickAll("div[id^=r_]"), owner: owner)
        self.once = root.pick("input[name=once]", .value)
        let rawReportUrl = root.pick("a[onclick*=/report/topic/]", .onclick)
        if rawReportUrl.notEmpty() {
            let sIndex = rawReportUrl.index(of: "/report/topic/")!
            let eIndex = rawReportUrl.lastIndex(of: "'")!
            self.reportLink = String(rawReportUrl[sIndex..<eIndex])
        }

        self.hasReported = root.pick("div.content div.box div.inner span.fade")
            .contains("已对本主题进行了报告")
        self.fadeStr = root.pick("a[onclick*=/fade/topic/]", .onclick)
        self.stickyStr = root.pick("a[onclick*=/sticky/topic/]", .onclick)
        log("feedDetailInfo: \(self)")
    }
}
