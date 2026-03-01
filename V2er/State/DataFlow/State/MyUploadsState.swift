//
//  MyUploadsState.swift
//  V2er
//
//  Created for V2er project
//  State for managing uploaded images history
//

import Foundation

struct MyUploadsState: FluxState {
    static let UPLOADS_KEY_PREFIX = "app.v2er.uploads"

    /// Per-user storage key for upload history.
    static var uploadsKey: String {
        guard let username = AccountManager.shared.activeUsername else {
            return UPLOADS_KEY_PREFIX
        }
        return "\(UPLOADS_KEY_PREFIX).\(username)"
    }
    static let maxUploadsHistory = 100

    var loading = false
    var uploads: [UploadRecord]?

    struct UploadRecord: Identifiable, Codable, Comparable {
        var id: String { imageUrl }
        var timestamp: Int64 = Date.currentTimeStamp
        var imageUrl: String
        var thumbnailUrl: String?

        init(imageUrl: String) {
            self.imageUrl = imageUrl
            // Imgur provides thumbnail by adding 't' before extension
            // e.g., https://i.imgur.com/abc.jpg -> https://i.imgur.com/abct.jpg
            self.thumbnailUrl = Self.makeThumbnailUrl(from: imageUrl)
        }

        static func makeThumbnailUrl(from url: String) -> String {
            // Imgur thumbnail: insert 't' before file extension for small thumbnail
            // 's' = small square, 't' = small thumbnail, 'm' = medium, 'l' = large
            // Only apply to Imgur URLs
            guard url.contains("imgur.com"),
                  let dotIndex = url.lastIndex(of: ".") else { return url }
            var result = url
            result.insert("t", at: dotIndex)
            return result
        }

        static func < (lhs: UploadRecord, rhs: UploadRecord) -> Bool {
            lhs.timestamp > rhs.timestamp // Descending order (newest first)
        }

        static func == (lhs: UploadRecord, rhs: UploadRecord) -> Bool {
            lhs.imageUrl == rhs.imageUrl
        }
    }

    // MARK: - Persistence (SwiftData-backed)

    @MainActor
    static func loadUploads() -> [UploadRecord] {
        let username = AccountManager.shared.activeUsername ?? ""
        return SyncDataService.fetchUploadRecords(for: username).map { ir in
            var record = UploadRecord(imageUrl: ir.imageUrl)
            record.timestamp = ir.timestamp
            record.thumbnailUrl = ir.thumbnailUrl.isEmpty ? nil : ir.thumbnailUrl
            return record
        }
    }

    @MainActor
    static func saveUpload(_ record: UploadRecord) {
        let username = AccountManager.shared.activeUsername ?? ""
        SyncDataService.saveUploadRecord(
            imageUrl: record.imageUrl,
            thumbnailUrl: record.thumbnailUrl ?? "",
            username: username
        )
    }

    @MainActor
    static func deleteUpload(_ record: UploadRecord) {
        let username = AccountManager.shared.activeUsername ?? ""
        SyncDataService.deleteUploadRecord(
            imageUrl: record.imageUrl,
            username: username
        )
    }
}
