//
//  TwoStepLoginResultInfo.swift
//  V2er
//
//  Created by ghui on 2021/12/2.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct TwoStepLoginResultInfo: BaseModel {
//    [href^=/member], href
    var userName: String
    // img[src*=avatar/], src
    var avatar: String

    init?(from html: Element?) {
        guard let root = html else { return nil }
        userName = root.pick("[href^=/member]", .href)
            .segment(separatedBy: "/", at: 2)
        avatar = root.pick("img[src*=avatar/]", .src)
    }

}
