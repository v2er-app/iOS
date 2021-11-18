//
//  DailyInfo.swift
//  V2er
//
//  Created by ghui on 2021/9/24.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct DailyInfo: BaseModel {
    var rawData: String?
    var userName: String = .default
    var avatar: String = .default
    var title: String = .default
    var checkedInDays: String = .default
    var hadCheckedIn: Bool = false
    var once: String = .default
    var checkedInUrl: String = .empty

    init() {}
    init(from html: Element?) {
        guard let root = html else { return }
        userName = root.pick("[href^=/member]", .href)
            .segment(separatedBy: "/", at: 2)
        avatar = parseAvatar(root.pick("img[src*=avatar/]", .src))
        title = root.pick("h1")
        checkedInDays = root.pick("div.cell:contains(已连续)")
            .extractDigits()
        checkedInUrl = root.pick("div.cell input[type=button]", .onclick)
        hadCheckedIn = !checkedInUrl.isEmpty && checkedInUrl.contains("location.href = '/balance';")
        once = checkedInUrl
            .segment(separatedBy: "?")
            .extractDigits()
    }

    func isValid() -> Bool {
        return notEmpty(checkedInUrl)
    }

}
