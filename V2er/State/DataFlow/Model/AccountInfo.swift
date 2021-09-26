//
//  AccountInfo.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct AccountInfo: Codable {
    var username: String
    var avatar: String

    func isValid() -> Bool {
        return notEmpty(username, avatar)
    }
}

