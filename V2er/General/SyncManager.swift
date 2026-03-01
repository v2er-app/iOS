//
//  SyncManager.swift
//  V2er
//
//  Manages SwiftData ModelContainer with optional iCloud CloudKit sync.
//

import Foundation
import SwiftData

@MainActor
final class SyncManager: ObservableObject {
    static let shared = SyncManager()

    private static let syncEnabledKey = "app.v2er.icloudSyncEnabled"

    var iCloudSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.syncEnabledKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.syncEnabledKey)
            rebuildContainer()
        }
    }

    private(set) var modelContainer: ModelContainer

    var mainContext: ModelContext {
        modelContainer.mainContext
    }

    private init() {
        modelContainer = Self.makeContainer(
            cloudKit: UserDefaults.standard.bool(forKey: Self.syncEnabledKey)
        )
    }

    private func rebuildContainer() {
        modelContainer = Self.makeContainer(cloudKit: iCloudSyncEnabled)
    }

    private static func makeContainer(cloudKit: Bool) -> ModelContainer {
        let schema = Schema([BrowsingRecord.self, ImageUploadRecord.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: cloudKit ? .automatic : .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
