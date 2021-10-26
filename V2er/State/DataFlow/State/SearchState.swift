//
//  SearchState.swift
//  V2er
//
//  Created by ghui on 2021/10/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct SearchState: FluxState {
    var updatable = UpdatableState()
    var keyword: String = .empty
    var sortWay: String = "sumup" // created

    var model: Model?

    struct Model: Codable {
        var total: Int
        var hits: [Hit] = []

        struct Hit: Codable, Identifiable {
            var source: Source
            var id: String {
                source.id.string
            }

            enum CodingKeys: String, CodingKey {
                case source = "_source"
            }

            struct Source: Codable {
                var id: Int
                var title: String
                var content: String
                // node
                var nodeId: Int
                // replies
                var replyNum: Int
                var created: String
                // member
                var creator: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case title
                    case content
                    case nodeId = "node"
                    case replyNum = "replies"
                    case created
                    case creator = "member"
                }
            }
        }
    }
}
