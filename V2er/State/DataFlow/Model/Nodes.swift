//
//  Nodes.swift
//  V2er
//
//  Created by ghui on 2021/10/23.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

typealias Nodes = [Node]

struct Node: Codable, Identifiable, Equatable {
    var id: String
    var text: String
    var topics: Int
}

// TODO consider to update it reguarlly via api
let HOT_NODES: Set<String> = ["qna", "jobs", "programmer",
                  "share", "macos", "create",
                  "apple", "python", "career",
                  "bb", "android", "iphone",
                  "gts", "mbp", "cv"]
