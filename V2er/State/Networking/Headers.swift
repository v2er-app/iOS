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
    static let TINY_REFERER = [REFERER : Endpoint.dailyMission.url.absoluteString]

    static func topicReferer(_ topicId: String) -> [String : String] {
        [REFERER : APIService.baseUrlString + "/t/\(topicId)"]
    }

    static func userReferer(_ username: String) -> [String : String] {
        [REFERER : APIService.baseUrlString + "/member/\(username)"]
    }

    static func refer(url: String) -> [String : String] {
        [REFERER : url]
    }
}

