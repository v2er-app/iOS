//
//  ThxAuthorInfo.swift
//  V2er
//
//  Created by ghui on 2021/11/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct ThxAuthorInfo: BaseModel {
    var link: String = .empty

    init?(from html: Element?) {
        guard let root = html else { return }
        link = root.pick("a[href=/balance]", .href)
    }

    func isValid() -> Bool {
        link.notEmpty()
    }

}
