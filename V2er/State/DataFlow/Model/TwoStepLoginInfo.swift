//
//  TwoStepLoginInfo.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct TwoStepInfo: BaseModel {
    var title: String?
    var once: String?

    init() {}

    init(from html: Element?) {
        guard let root = html?.pickOne("form[method=post]") else { return }
        title = root.pick("tr:first-child")
        once = root.pick("input[type=hidden]", .value)
    }

    func isValid() -> Bool {
        guard let once = once, let title = title else {
            return false
        }
        return !once.isEmpty
        && !title.isEmpty
        && title.contains("两步验证")
    }
}
