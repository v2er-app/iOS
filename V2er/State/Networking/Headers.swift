//
//  Headers.swift
//  V2er
//
//  Created by ghui on 2021/11/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct Headers {

    static let REFERER: String = "Referer"

    static func topicReferer(_ topicId: String) -> String {
        return APIService.baseUrlString + "/t/\(topicId)"
    }
}

