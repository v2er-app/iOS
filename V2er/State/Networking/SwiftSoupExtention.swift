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
    func pick(_ selector: String, at index:Int = 0,
              _ attr: HtmlAttr = .text, regex: String? = nil) -> String {
        let e : Element? = pickAll(selector)[safe: index]
        guard let e = e else { return .default }
        let result: String?
        if attr == .text {
            result = try? e.text()
        } else if attr == .ownText {
            result = e.ownText()
        } else {
            result = try? e.attr(attr.value)
        }
        // TODO use reg
        return result ?? .default
    }

    func pickAll(_ selector: String) -> Elements {
        if let result = try? self.select(selector) {
            return result
        }
        return Elements()
    }

    func pickOne(_ selector: String, at index:Int = 0) -> Element? {
        if let result = pickAll(selector)[safe: index] {
            return result
        }
        return nil
    }

    func value(_ attr: HtmlAttr = .text) -> String {
        let result: String?
        if attr == .text {
            result = try? self.text()
        } else if attr == .ownText {
            result = self.ownText()
        } else {
            result = try? self.attr(attr.value)
        }
        return result ?? .default
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

    var value: String {
        get { self.rawValue }
    }
}


