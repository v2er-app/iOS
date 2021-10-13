//
//  HistoryInfo.swift
//  V2er
//
//  Created by ghui on 2021/10/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct MyRecentState: FluxState {
    static let RECORD_KEY = "app.v2er.record"
    var loading = false
    var records: [Record]?

    struct Record: FeedItemProtocol, Codable, Comparable {
        var timestamp: Int64 = Date.currentTimeStamp
        var id: String
        var title: String?
        var avatar: String?
        var userName: String?
        var replyUpdate: String?
        var nodeName: String?
        var nodeId: String?
        var replyNum: String?

        init(id: String, title: String?, avatar: String?) {
            self.init(id: id, title: title, avatar: avatar, userName: .empty)
        }

        init(id: String,
             title: String?,
             avatar: String?,
             userName: String? = .empty,
             replyUpdate: String? = .empty,
             nodeName: String? = .empty,
             nodeId: String? = .empty,
             replyNum: String? = .empty
        ) {
            self.id = id
            self.title = title
            self.avatar = avatar
            self.userName = userName
            self.replyUpdate = replyUpdate
            self.nodeName = nodeName
            self.nodeId = nodeId
            self.replyNum = replyNum
        }

        static func < (lhs: MyRecentState.Record, rhs: MyRecentState.Record) -> Bool {
            lhs.timestamp < rhs.timestamp
        }

        static func == (lhs: MyRecentState.Record, rhs: MyRecentState.Record) -> Bool {
            lhs.id == rhs.id
        }
    }

}
