//
//  MigrationService.swift
//  V2er
//
//  One-time migration from UserDefaults (Persist) to SwiftData.
//

import Foundation

@MainActor
struct MigrationService {
    private static let migrationKey = "app.v2er.migration.swiftdata.completed"

    static func migrateIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        let accounts = AccountManager.shared.accounts
        let usernames: [String] = accounts.map(\.username)

        // Also attempt migration for the anonymous prefix (no username suffix)
        var keySuffixes = usernames
        keySuffixes.append("") // anonymous / legacy data

        for suffix in keySuffixes {
            migrateBrowsingRecords(usernameSuffix: suffix)
            migrateUploadRecords(usernameSuffix: suffix)
        }

        UserDefaults.standard.set(true, forKey: migrationKey)
        log("SwiftData migration completed")
    }

    // MARK: - Browsing History

    private static func migrateBrowsingRecords(usernameSuffix: String) {
        let key = usernameSuffix.isEmpty
            ? MyRecentState.RECORD_KEY_PREFIX
            : "\(MyRecentState.RECORD_KEY_PREFIX).\(usernameSuffix)"

        guard let data = Persist.read(key: key) else { return }
        guard let records = try? JSONDecoder().decode([MyRecentState.Record].self, from: data) else { return }

        let username = usernameSuffix.isEmpty
            ? (AccountManager.shared.activeUsername ?? "")
            : usernameSuffix

        for record in records {
            SyncDataService.saveBrowsingRecord(
                topicId: record.id,
                username: username,
                title: record.title ?? "",
                avatar: record.avatar ?? "",
                authorName: record.userName ?? "",
                replyUpdate: record.replyUpdate ?? "",
                nodeName: record.nodeName ?? "",
                nodeId: record.nodeId ?? "",
                replyNum: record.replyNum ?? ""
            )
        }

        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Upload History

    private static func migrateUploadRecords(usernameSuffix: String) {
        let key = usernameSuffix.isEmpty
            ? MyUploadsState.UPLOADS_KEY_PREFIX
            : "\(MyUploadsState.UPLOADS_KEY_PREFIX).\(usernameSuffix)"

        guard let data = Persist.read(key: key) else { return }
        guard let records = try? JSONDecoder().decode([MyUploadsState.UploadRecord].self, from: data) else { return }

        let username = usernameSuffix.isEmpty
            ? (AccountManager.shared.activeUsername ?? "")
            : usernameSuffix

        for record in records {
            SyncDataService.saveUploadRecord(
                imageUrl: record.imageUrl,
                thumbnailUrl: record.thumbnailUrl ?? "",
                username: username
            )
        }

        UserDefaults.standard.removeObject(forKey: key)
    }
}
