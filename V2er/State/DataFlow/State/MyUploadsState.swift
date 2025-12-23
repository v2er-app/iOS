//
//  MyUploadsState.swift
//  V2er
//
//  Created for V2er project
//  State for managing uploaded images history
//

import Foundation

struct MyUploadsState: FluxState {
    static let UPLOADS_KEY = "app.v2er.uploads"
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

    // MARK: - Persistence

    static func loadUploads() -> [UploadRecord] {
        guard let data = Persist.read(key: UPLOADS_KEY) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([UploadRecord].self, from: data)) ?? []
    }

    static func saveUpload(_ record: UploadRecord) {
        var uploads = loadUploads()
        // Remove duplicate if exists
        uploads.removeAll { $0.imageUrl == record.imageUrl }
        // Add to beginning
        uploads.insert(record, at: 0)
        // Keep only last N uploads
        if uploads.count > maxUploadsHistory {
            uploads = Array(uploads.prefix(maxUploadsHistory))
        }
        saveUploads(uploads)
    }

    static func saveUploads(_ uploads: [UploadRecord]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(uploads) {
            Persist.save(value: data, forkey: UPLOADS_KEY)
        }
    }

    static func deleteUpload(_ record: UploadRecord) {
        var uploads = loadUploads()
        uploads.removeAll { $0.imageUrl == record.imageUrl }
        saveUploads(uploads)
    }
}
