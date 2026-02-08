//
//  App.swift
//  V2er
//
//  Created by Seth on 2020/7/1.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import Combine

@main
struct V2erApp: App {
    public static let deviceType = UIDevice().type
    public static var rootViewController: UIViewController?
    public static var statusBarState: UIStatusBarStyle = .darkContent
    public static var window: UIWindow?
    @StateObject private var store = Store.shared

    init() {
        setupApperance()
    }
    
    private func setupApperance() {
        // Navigation bar appearance will be set dynamically based on color scheme
        let navAppearance = UINavigationBar.appearance()
        navAppearance.isTranslucent = true
    }
    
    var body: some Scene {
        WindowGroup {
            RootView {
                RootHostView()
                    .environmentObject(store)
            }            .onAppear {
                updateAppearance(store.appState.settingState.appearance)
                // Record launch and refresh other apps badge
                OtherAppsManager.shared.recordLaunch()
                OtherAppsManager.shared.refreshBadge()
            }            .onChange(of: store.appState.settingState.appearance) { newValue in
                updateAppearance(newValue)
            }        }
    }

    private func updateAppearance(_ appearance: AppearanceMode) {
        updateNavigationBarAppearance(for: appearance)
        updateWindowInterfaceStyle(for: appearance)
    }

    static func updateAppearanceStatic(_ appearance: AppearanceMode) {
        updateNavigationBarAppearanceStatic(for: appearance)
        updateWindowInterfaceStyleStatic(for: appearance)
    }
    
    static func updateNavigationBarAppearanceStatic(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            let navbarAppearance = UINavigationBarAppearance()
            navbarAppearance.backgroundColor = .clear

            let navAppearance = UINavigationBar.appearance()
            navAppearance.standardAppearance = navbarAppearance
            navAppearance.compactAppearance = navbarAppearance
            navAppearance.scrollEdgeAppearance = navbarAppearance
            navAppearance.backgroundColor = .clear
        }
    }

    private func updateNavigationBarAppearance(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            let navbarAppearance = UINavigationBarAppearance()
            navbarAppearance.backgroundColor = .clear

            let navAppearance = UINavigationBar.appearance()
            navAppearance.standardAppearance = navbarAppearance
            navAppearance.compactAppearance = navbarAppearance
            navAppearance.scrollEdgeAppearance = navbarAppearance
            navAppearance.backgroundColor = .clear
        }
    }
    
    static func updateWindowInterfaceStyleStatic(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            let style: UIUserInterfaceStyle
            switch appearance {
            case .light:
                style = .light
            case .dark:
                style = .dark
            case .system:
                style = .unspecified
            }

            // Update all connected scenes
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style
                    }                }            }
            // Also update the stored window if available
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
            }
            // Update the root hosting controller
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearanceFromString(appearance.rawValue)
            }
            // Force a redraw
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { $0.setNeedsDisplay() }
                }            }        }
    }

    private func updateWindowInterfaceStyle(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            let style: UIUserInterfaceStyle
            switch appearance {
            case .light:
                style = .light
            case .dark:
                style = .dark
            case .system:
                style = .unspecified
            }

            // Update all connected scenes
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style
                    }                }            }
            // Also update the stored window if available
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
            }
            // Update the root hosting controller
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearanceFromString(appearance.rawValue)
            }
            // Force a redraw
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { $0.setNeedsDisplay() }
                }            }        }
    }

    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        guard style != statusBarState else { return }
        statusBarState = style
        rootViewController?
            .setNeedsStatusBarAppearanceUpdate()
    }

}




