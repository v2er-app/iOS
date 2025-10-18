//
//  OnlineStatsInfo.swift
//  V2er
//
//  Created by ghui on 2025/10/18.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

public struct OnlineStatsInfo: BaseModel, Codable {
    var rawData: String?
    var onlineCount: Int = 0
    var maxRecord: Int = 0

    init() {}

    enum CodingKeys: String, CodingKey {
        case onlineCount, maxRecord
    }

    init?(from html: Element?) {
        guard let root = html else {
            log("OnlineStatsInfo: root element is nil")
            return nil
        }

        // Parse from footer HTML
        // Structure: <strong>... 2576 人在线</strong> &nbsp; <span class="fade">最高记录 6679</span>

        // Get all text content from the page
        let pageText = root.value(.text)

        // Extract online count using simple pattern matching
        // Pattern: "数字 人在线"
        let onlinePattern = "(\\d+)\\s*人在线"
        if let regex = try? NSRegularExpression(pattern: onlinePattern) {
            let nsText = pageText as NSString
            let matches = regex.matches(in: pageText, range: NSRange(location: 0, length: nsText.length))
            if let match = matches.first, match.numberOfRanges > 1 {
                let numberStr = nsText.substring(with: match.range(at: 1))
                onlineCount = Int(numberStr.replacingOccurrences(of: ",", with: "")) ?? 0
                log("OnlineStatsInfo: Found online count = \(onlineCount)")
            }
        }

        // Extract max record
        let maxPattern = "最高记录\\s+(\\d+)"
        if let regex = try? NSRegularExpression(pattern: maxPattern) {
            let nsText = pageText as NSString
            let matches = regex.matches(in: pageText, range: NSRange(location: 0, length: nsText.length))
            if let match = matches.first, match.numberOfRanges > 1 {
                let numberStr = nsText.substring(with: match.range(at: 1))
                maxRecord = Int(numberStr.replacingOccurrences(of: ",", with: "")) ?? 0
                log("OnlineStatsInfo: Found max record = \(maxRecord)")
            }
        }

        // If we didn't find the data, return nil
        if onlineCount == 0 {
            log("OnlineStatsInfo: Parse failed, onlineCount = 0")
            return nil
        }
    }

    private func extractNumber(before keyword: String, from text: String) -> Int? {
        let components = text.components(separatedBy: keyword)
        guard let firstPart = components.first else { return nil }

        // Extract the last number from the text before keyword
        let pattern = "(\\d+)\\s*$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let nsText = firstPart as NSString
        let matches = regex.matches(in: firstPart, range: NSRange(location: 0, length: nsText.length))

        if let match = matches.last, match.numberOfRanges > 1 {
            let numberStr = nsText.substring(with: match.range(at: 1))
            return Int(numberStr.replacingOccurrences(of: ",", with: ""))
        }

        return nil
    }

    private func extractNumber(after keyword: String, from text: String) -> Int? {
        let components = text.components(separatedBy: keyword)
        guard components.count > 1 else { return nil }

        let afterPart = components[1]

        // Extract the first number from the text after keyword
        let pattern = "(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let nsText = afterPart as NSString
        let matches = regex.matches(in: afterPart, range: NSRange(location: 0, length: nsText.length))

        if let match = matches.first, match.numberOfRanges > 1 {
            let numberStr = nsText.substring(with: match.range(at: 1))
            return Int(numberStr.replacingOccurrences(of: ",", with: ""))
        }

        return nil
    }

    func isValid() -> Bool {
        return onlineCount > 0
    }
}
