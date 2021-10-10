//
//  HistoryInfo.swift
//  V2er
//
//  Created by ghui on 2021/10/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct MyRecentState: FluxState {
    var loading = false
    var model: Model?

    struct Model {
        var items: [Item]

        struct Item: FeedItemProtocol, Codable {
            var id: String
            var title: String?
            var avatar: String?
            var userName: String?
            var replyUpdate: String?
            var nodeName: String?
            var nodeId: String?
            var replyNum: String?

            init(id: String, title: String?, avatar: String?) {
                self.id = id
                self.title = title
                self.avatar = avatar
            }

//            init(id: String, title: String?, avatar: String?, userName: String?, replyUpdate: String?, nodeName: String?, nodeId: String?, replyNum: String?) {
//                self.id = id
//                self.title = title
//                self.avatar = avatar
//                self.userName = userName
//                self.replyUpdate = replyUpdate
//                self.nodeName = nodeName
//                self.nodeId = replyNum
//            }

        }
    }
}
