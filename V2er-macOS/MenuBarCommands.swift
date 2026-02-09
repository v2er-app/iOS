//
//  MenuBarCommands.swift
//  V2er
//
//  macOS menu bar commands (Cmd+R to refresh, Cmd+1-4 for tabs).
//

import SwiftUI

struct V2erCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("刷新") {
                // Trigger a feed refresh via the existing action system
                dispatch(FeedActions.FetchData.Start())
            }
            .keyboardShortcut("r", modifiers: .command)
        }
    }
}
