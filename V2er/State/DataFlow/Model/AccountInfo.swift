//
//  AccountInfo.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct BalanceInfo: BaseModel, Codable {
    var rawData: String?
    var gold: Int = 0
    var silver: Int = 0
    var bronze: Int = 0

    init() {}

    enum CodingKeys: String, CodingKey {
        case gold, silver, bronze
    }

    init(from html: Element?) {
        guard let root = html else { return }

        // Strategy 1: Parse from div.balance_area (main balance page from /balance endpoint)
        // HTML: <div class="balance_area bigger">47 <img src="/static/img/gold@2x.png"> 28 <img src="/static/img/silver@2x.png"> 26 <img src="/static/img/bronze@2x.png"></div>
        if let balanceDiv = root.pickOne("div.balance_area") {
            parseFromBalanceDiv(balanceDiv)
        }

        // Strategy 2: Parse from div#money (alternative format, might be on homepage)
        // HTML: <div id="money"><a href="/balance" class="balance_area">47 <img...> 28 <img...> 26 <img...></a></div>
        if gold == 0 && silver == 0 && bronze == 0 {
            if let moneyDiv = root.pickOne("div#money a.balance_area") {
                parseFromBalanceDiv(moneyDiv)
            }
        }

        // Strategy 3: Parse from table cells (alternative format)
        // Structure: table.data > tbody > tr > td
        if gold == 0 && silver == 0 && bronze == 0 {
            parseFromTableCells(root: root)
        }

        // Strategy 4: Parse from table rows with separate cells
        // Some V2EX pages show balance as: <td align="right">47</td><td>金币</td>
        if gold == 0 && silver == 0 && bronze == 0 {
            parseFromTableRows(root: root)
        }
    }

    private mutating func parseFromBalanceDiv(_ element: Element) {
        // Parse from: "47 <img src="/static/img/gold@2x.png"> 28 <img src="/static/img/silver@2x.png"> 26 <img src="/static/img/bronze@2x.png">"
        // Numbers can have commas: "2,025 <img> 101 <img> 344 <img>"

        // Get the HTML to parse text nodes between img tags
        guard let html = try? element.html() else { return }

        // Replace img tags with a delimiter, then split
        // The pattern is: NUMBER <img...> NUMBER <img...> NUMBER <img...>
        let imgPattern = "<img[^>]*>"
        guard let regex = try? NSRegularExpression(pattern: imgPattern, options: []) else { return }

        let nsHtml = html as NSString
        let cleanedHtml = regex.stringByReplacingMatches(
            in: html,
            range: NSRange(location: 0, length: nsHtml.length),
            withTemplate: "|"  // Use | as delimiter
        )

        // Split by delimiter and extract numbers
        let parts = cleanedHtml.components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Extract first number from each part (handling commas)
        var numbers: [Int] = []
        let numberPattern = "[0-9,]+"
        guard let numberRegex = try? NSRegularExpression(pattern: numberPattern) else { return }

        for part in parts {
            let nsPart = part as NSString
            let matches = numberRegex.matches(in: part, range: NSRange(location: 0, length: nsPart.length))
            if let firstMatch = matches.first {
                let numStr = nsPart.substring(with: firstMatch.range)
                if let num = parseNumber(numStr) {
                    numbers.append(num)
                }
            }
        }

        // Assign in order: gold, silver, bronze
        if numbers.count >= 1 { gold = numbers[0] }
        if numbers.count >= 2 { silver = numbers[1] }
        if numbers.count >= 3 { bronze = numbers[2] }
    }

    private mutating func parseFromTableCells(root: Element) {
        // Try to parse from cells that contain balance information
        // V2EX balance page typically shows: "XX 金币", "XX 银币", "XX 铜币"
        let cells = root.pickAll("table.data tbody tr td")

        for cell in cells {
            let text = cell.value(.text)

            if text.contains("金币") {
                gold = extractNumberBefore(keyword: "金币", from: text)
            } else if text.contains("银币") {
                silver = extractNumberBefore(keyword: "银币", from: text)
            } else if text.contains("铜币") {
                bronze = extractNumberBefore(keyword: "铜币", from: text)
            }
        }
    }

    private mutating func parseFromTableRows(root: Element) {
        // Try alternative parsing method for table rows
        let rows = root.pickAll("table.data tbody tr")

        for row in rows {
            let cellsArray = row.pickAll("td").array()
            if cellsArray.count >= 2 {
                let valueCell = cellsArray[0].value(.text).trimmingCharacters(in: .whitespacesAndNewlines)
                let labelCell = cellsArray[1].value(.text).trimmingCharacters(in: .whitespacesAndNewlines)

                if let value = parseNumber(valueCell) {
                    if labelCell.contains("金币") {
                        gold = value
                    } else if labelCell.contains("银币") {
                        silver = value
                    } else if labelCell.contains("铜币") {
                        bronze = value
                    }
                }
            }
        }
    }

    private func parseNumber(_ text: String) -> Int? {
        // Remove commas and parse the number
        // Example: "2,025,101,344" -> 2025101344
        // Example: "47" -> 47
        let cleaned = text.replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(cleaned)
    }

    private func extractNumberBefore(keyword: String, from text: String) -> Int {
        // Extract number before the keyword, handling commas
        // Example: "47 金币" -> 47
        // Example: "2,025 金币" -> 2025
        let components = text.components(separatedBy: keyword)
        if let firstPart = components.first {
            let cleaned = firstPart.trimmingCharacters(in: .whitespacesAndNewlines)
            return parseNumber(cleaned) ?? 0
        }
        return 0
    }

    func isValid() -> Bool {
        return gold > 0 || silver > 0 || bronze > 0
    }
}

struct AccountInfo: Codable {
    var username: String
    var avatar: String
    var balance: BalanceInfo?

    func isValid() -> Bool {
        return notEmpty(username, avatar)
    }
}

