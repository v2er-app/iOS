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
        // Extract consecutive days using regex pattern "X 天"
        let daysText = root.pick("div.cell:contains(已连续)")
        checkedInDays = DailyInfo.extractDays(from: daysText)
        checkedInUrl = root.pick("div.cell input[type=button]", .onclick)
        hadCheckedIn = !checkedInUrl.isEmpty && checkedInUrl.contains("location.href = '/balance';")
        once = checkedInUrl
            .segment(separatedBy: "?")
            .extractDigits()
    }

    func isValid() -> Bool {
        return notEmpty(checkedInUrl)
    }

    /// Extract days from strings like "已连续登录 123 天" or "ghui 已连续签到 12 天 2024/12/25"
    private static func extractDays(from text: String) -> String {
        guard !text.isEmpty else { return .default }
        // Use regex to find number followed by "天" (days)
        let pattern = "(\\d+)\\s*天"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return .default
        }
        return String(text[range])
    }
}
