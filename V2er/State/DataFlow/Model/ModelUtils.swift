//
//  Utils.swift
//  Utils
//
//  Created by ghui on 2021/9/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation


func parseAvatar(_ link: String) -> String {
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
