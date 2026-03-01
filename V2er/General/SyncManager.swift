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
    private static let cloudKitContainerID = "iCloud.v2er.app"

    var iCloudSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.syncEnabledKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.syncEnabledKey)
        }
    }

    private(set) var modelContainer: ModelContainer

    var mainContext: ModelContext {
        modelContainer.mainContext
    }

    private init() {
        // Default to enabled for new installs
        if UserDefaults.standard.object(forKey: Self.syncEnabledKey) == nil {
            UserDefaults.standard.set(true, forKey: Self.syncEnabledKey)
        }
        let useCloudKit = UserDefaults.standard.bool(forKey: Self.syncEnabledKey)
        let schema = Schema([BrowsingRecord.self, ImageUploadRecord.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: useCloudKit ? .private(Self.cloudKitContainerID) : .none
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            log("ModelContainer with cloudKit=\(useCloudKit) failed: \(error), retrying local-only")
            let localConfig = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .none
            )
            do {
                modelContainer = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Failed to create local ModelContainer: \(error)")
            }
        }
    }
}
