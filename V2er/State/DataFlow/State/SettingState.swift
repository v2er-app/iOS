//
//  SettingState.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingState: FluxState {
    var appearance: AppearanceMode = .system

    init() {
        // Load saved preference
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode"),
           let mode = AppearanceMode(rawValue: savedMode) {
            self.appearance = mode
            print("📱 Loaded saved appearance: \(mode.rawValue)")
        } else {
            print("📱 No saved appearance, using default: system")
        }
    }
}

enum AppearanceMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        case .system:
            return "跟随系统"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

// Temporary: Define actions here until SettingActions.swift is properly added to project
struct SettingActions {
    private static let R: Reducer = .setting
    
    struct ChangeAppearanceAction: Action {
        var target: Reducer = R
        let appearance: AppearanceMode
    }
}