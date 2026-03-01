//
//  SyncModels.swift
//  V2er
//
//  SwiftData models for iCloud-synced browsing history and upload records.
//

import Foundation
import SwiftData

@Model
final class BrowsingRecord {
    #Unique<BrowsingRecord>([\.topicId, \.username])

    var topicId: String = ""
    var username: String = ""
    var timestamp: Int64 = 0
    var title: String = ""
    var avatar: String = ""
    var authorName: String = ""
    var replyUpdate: String = ""
    var nodeName: String = ""
    var nodeId: String = ""
    var replyNum: String = ""

    init(
        topicId: String,
        username: String,
        timestamp: Int64 = Date.currentTimeStamp,
        title: String = "",
        avatar: String = "",
        authorName: String = "",
        replyUpdate: String = "",
        nodeName: String = "",
        nodeId: String = "",
        replyNum: String = ""
    ) {
        self.topicId = topicId
        self.username = username
        self.timestamp = timestamp
        self.title = title
        self.avatar = avatar
        self.authorName = authorName
        self.replyUpdate = replyUpdate
        self.nodeName = nodeName
        self.nodeId = nodeId
        self.replyNum = replyNum
    }
}

@Model
final class ImageUploadRecord {
    #Unique<ImageUploadRecord>([\.imageUrl, \.username])

    var imageUrl: String = ""
    var thumbnailUrl: String = ""
    var username: String = ""
    var timestamp: Int64 = 0
    @Attribute(.externalStorage) var imageData: Data?

    init(
        imageUrl: String,
        thumbnailUrl: String = "",
        username: String = "",
        timestamp: Int64 = Date.currentTimeStamp,
        imageData: Data? = nil
    ) {
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.username = username
        self.timestamp = timestamp
        self.imageData = imageData
    }
}
