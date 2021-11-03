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
              _ attr: HtmlAttr = .text, regex: String? = nil, `default`: String = .empty) -> String {
        let es: Elements = pickAll(selector)
        let index = min(index, es.count - 1)
        let e : Element? = es[safe: index]
        guard let e = e else { return `default` }
        let result: String?
        if attr == .text {
            result = try? e.text()
        } else if attr == .ownText {
            result = e.ownText()
        } else if attr == .innerHtml {
            result = try? e.html()
        } else {
            result = try? e.attr(attr.value)
        }
        // TODO use reg
        return result.isEmpty ? `default` : result!
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
        } else if attr == .html {
            result = try? self.outerHtml()
        } else if attr == .innerHtml {
            result = try? self.html()
        } else {
            result = try? self.attr(attr.value)
        }
        return result ?? .default
    }

    @discardableResult func remove(selector: String) -> Element {
        try? pickAll(selector).remove()
        return self
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
    case content = "content"
    case onclick = "onclick"
    case id = "id"
    case alt = "alt"
    case name = "name"

    var value: String {
        get { self.rawValue }
    }
}


