//
//  Utils.swift
//  Utils
//
//  Created by ghui on 2021/9/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation


func parseAvatar(_ link: String) -> String {
    // Check whether is start with http
    var link = link
    if !link.starts(with: APIService.HTTP) {
        if link.starts(with: "//") {
            link = APIService.HTTPS + link
        } else if link.starts(with: "/") {
            link = APIService.baseUrlString + link
        }
    }
    return link
        .segment(separatedBy: "?m", at: .first)
        .replace(segs: "_normal.png", "_mini.png", "_xxlarge.png",
                 with: "_large.png")
}

func parseFeedId(_ link: String) -> String {
    return link
        .remove("/t/")
        .segment(separatedBy: "#", at: .first)
}

func parseReplyUpdate(_ timeReplier: String) -> String {
    let result: String
    if timeReplier.contains("来自") {
        let time = timeReplier.segment(separatedBy: "•", at: .first)
            .trim()
        let replier = timeReplier.segment(separatedBy: "来自").trim()
        result = time.appending(" \(replier) ")
            .appending("回复了")
    } else {
        result = timeReplier
    }
    return result
}
