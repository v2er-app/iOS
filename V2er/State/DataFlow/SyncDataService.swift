//
//  SyncDataService.swift
//  V2er
//
//  CRUD layer over SwiftData for browsing history and upload records.
//

import Foundation
import SwiftData

@MainActor
struct SyncDataService {

    private static var context: ModelContext {
        SyncManager.shared.mainContext
    }

    // MARK: - Browsing Records

    static let maxBrowsingRecords = 500

    static func fetchBrowsingRecords(for username: String) -> [BrowsingRecord] {
        var descriptor = FetchDescriptor<BrowsingRecord>(
            predicate: #Predicate { $0.username == username },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = maxBrowsingRecords
        do {
            return try context.fetch(descriptor)
        } catch {
            log("fetchBrowsingRecords failed: \(error)")
            return []
        }
    }

    static func saveBrowsingRecord(
        topicId: String,
        username: String,
        title: String,
        avatar: String,
        authorName: String,
        replyUpdate: String = "",
        nodeName: String,
        nodeId: String,
        replyNum: String
    ) {
        // Check for existing record (upsert)
        let predicate = #Predicate<BrowsingRecord> {
            $0.topicId == topicId && $0.username == username
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            let results = try context.fetch(descriptor)
            if let existing = results.first {
                existing.timestamp = Date.currentTimeStamp
                existing.title = title
                existing.avatar = avatar
                existing.authorName = authorName
                existing.replyUpdate = replyUpdate
                existing.nodeName = nodeName
                existing.nodeId = nodeId
                existing.replyNum = replyNum
            } else {
                let record = BrowsingRecord(
                    topicId: topicId,
                    username: username,
                    title: title,
                    avatar: avatar,
                    authorName: authorName,
                    replyUpdate: replyUpdate,
                    nodeName: nodeName,
                    nodeId: nodeId,
                    replyNum: replyNum
                )
                context.insert(record)
                trimBrowsingRecords(for: username)
            }
            try context.save()
        } catch {
            log("saveBrowsingRecord failed: \(error)")
        }
    }

    private static func trimBrowsingRecords(for username: String) {
        var descriptor = FetchDescriptor<BrowsingRecord>(
            predicate: #Predicate { $0.username == username },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchOffset = maxBrowsingRecords
        if let excess = try? context.fetch(descriptor) {
            for record in excess {
                context.delete(record)
            }
        }
    }

    // MARK: - Upload Records

    static let maxUploadRecords = 1000

    static func fetchUploadRecords(for username: String) -> [ImageUploadRecord] {
        var descriptor = FetchDescriptor<ImageUploadRecord>(
            predicate: #Predicate { $0.username == username },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = maxUploadRecords
        do {
            return try context.fetch(descriptor)
        } catch {
            log("fetchUploadRecords failed: \(error)")
            return []
        }
    }

    static func saveUploadRecord(imageUrl: String, thumbnailUrl: String, username: String) {
        // Check for existing record (upsert)
        let predicate = #Predicate<ImageUploadRecord> {
            $0.imageUrl == imageUrl && $0.username == username
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            let results = try context.fetch(descriptor)
            if let existing = results.first {
                existing.timestamp = Date.currentTimeStamp
                existing.thumbnailUrl = thumbnailUrl
            } else {
                let record = ImageUploadRecord(
                    imageUrl: imageUrl,
                    thumbnailUrl: thumbnailUrl,
                    username: username
                )
                context.insert(record)
                trimUploadRecords(for: username)
            }
            try context.save()
        } catch {
            log("saveUploadRecord failed: \(error)")
        }
    }

    static func deleteUploadRecord(imageUrl: String, username: String) {
        let predicate = #Predicate<ImageUploadRecord> {
            $0.imageUrl == imageUrl && $0.username == username
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        do {
            let records = try context.fetch(descriptor)
            for record in records {
                context.delete(record)
            }
            try context.save()
        } catch {
            log("deleteUploadRecord failed: \(error)")
        }
    }

    static func updateUploadImageData(imageUrl: String, username: String, data: Data) {
        let predicate = #Predicate<ImageUploadRecord> {
            $0.imageUrl == imageUrl && $0.username == username
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            if let record = try context.fetch(descriptor).first {
                record.imageData = data
                try context.save()
            }
        } catch {
            log("updateUploadImageData failed: \(error)")
        }
    }

    private static func trimUploadRecords(for username: String) {
        var descriptor = FetchDescriptor<ImageUploadRecord>(
            predicate: #Predicate { $0.username == username },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchOffset = maxUploadRecords
        if let excess = try? context.fetch(descriptor) {
            for record in excess {
                context.delete(record)
            }
        }
    }
}
