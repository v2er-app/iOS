//
//  ParseUtils.swift
//  ParseUtils
//
//  Created by ghui on 2021/8/18.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup


public extension Element {
    func pick(_ selector: String, _ attr: HtmlAttr = .text) -> String {
        if let result = try? self.select(selector).attr(attr.rawValue) {
            return result
        }
        return ""
    }

    func pickAll(_ selector: String) -> Elements? {
        if let result = try? self.select(selector) {
            return result
        }
        return nil
    }

    func pickOne(_ selector: String) -> Element? {
        if let result = pickAll(selector)?[0] {
            return result
        }
        return nil
    }

}

public enum HtmlAttr: String {
    case text = "text"
    case ownText = "ownText"
    case href = "href"
    case src = "src"
    case value = "value"
    case html = "html"
    case innerHtml = "inner_html"
}
