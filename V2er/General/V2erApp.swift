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
        setupNotifications()
        // Apply saved theme on app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let savedAppearance = Store.shared.appState.settingState.appearance
            print("🚀 Applying saved appearance on launch: \(savedAppearance.rawValue)")
            V2erApp.updateAppearanceStatic(savedAppearance)
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AppearanceDidChange"),
            object: nil,
            queue: .main
        ) { notification in
            if let appearance = notification.object as? AppearanceMode {
                print("📱 Received appearance change notification: \(appearance.rawValue)")
                V2erApp.updateAppearanceStatic(appearance)
            }
        }
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
            }
            .preferredColorScheme(store.appState.settingState.appearance.colorScheme)
            .onAppear {
                updateAppearance(store.appState.settingState.appearance)
            }
            .onChange(of: store.appState.settingState.appearance) { newValue in
                updateAppearance(newValue)
            }
        }
    }

    private func updateAppearance(_ appearance: AppearanceMode) {
        print("🔄 Updating appearance to: \(appearance.rawValue)")
        updateNavigationBarAppearance(for: appearance)
        updateWindowInterfaceStyle(for: appearance)
    }

    static func updateAppearanceStatic(_ appearance: AppearanceMode) {
        print("🔄 Updating appearance to: \(appearance.rawValue)")
        updateNavigationBarAppearanceStatic(for: appearance)
        updateWindowInterfaceStyleStatic(for: appearance)
    }
    
    static func updateNavigationBarAppearanceStatic(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            let navbarAppearance = UINavigationBarAppearance()

            // Determine if we should use dark mode
            let isDarkMode: Bool
            switch appearance {
            case .light:
                isDarkMode = false
            case .dark:
                isDarkMode = true
            case .system:
                isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
            }

            let tintColor = isDarkMode ? UIColor.white : UIColor.black
            navbarAppearance.titleTextAttributes = [.foregroundColor: tintColor]
            navbarAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
            navbarAppearance.backgroundColor = .clear

            let navAppearance = UINavigationBar.appearance()
            navAppearance.standardAppearance = navbarAppearance
            navAppearance.compactAppearance = navbarAppearance
            navAppearance.scrollEdgeAppearance = navbarAppearance
            navAppearance.backgroundColor = .clear
            navAppearance.tintColor = tintColor

            // Force refresh of current navigation controllers
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.subviews.forEach { _ in
                        window.tintColor = tintColor
                    }
                }
            }
        }
    }

    private func updateNavigationBarAppearance(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            let navbarAppearance = UINavigationBarAppearance()

            // Determine if we should use dark mode
            let isDarkMode: Bool
            switch appearance {
            case .light:
                isDarkMode = false
            case .dark:
                isDarkMode = true
            case .system:
                isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
            }

            let tintColor = isDarkMode ? UIColor.white : UIColor.black
            navbarAppearance.titleTextAttributes = [.foregroundColor: tintColor]
            navbarAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
            navbarAppearance.backgroundColor = .clear

            let navAppearance = UINavigationBar.appearance()
            navAppearance.standardAppearance = navbarAppearance
            navAppearance.compactAppearance = navbarAppearance
            navAppearance.scrollEdgeAppearance = navbarAppearance
            navAppearance.backgroundColor = .clear
            navAppearance.tintColor = tintColor

            // Force refresh of current navigation controllers
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.subviews.forEach { _ in
                        window.tintColor = tintColor
                    }
                }
            }
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

            print("🪟 Setting window interface style to: \(style.rawValue)")

            // Update all connected scenes
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style
                        print("  ✓ Updated window: \(window)")
                    }
                }
            }

            // Also update the stored window if available
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
                print("  ✓ Updated stored window")
            }

            // Update the root hosting controller
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearanceFromString(appearance.rawValue)
                print("  ✓ Updated root hosting controller")
            }

            // Force a redraw
            UIApplication.shared.windows.forEach { $0.setNeedsDisplay() }
        }
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

            print("🪟 Setting window interface style to: \(style.rawValue)")

            // Update all connected scenes
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style
                        print("  ✓ Updated window: \(window)")
                    }
                }
            }

            // Also update the stored window if available
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
                print("  ✓ Updated stored window")
            }

            // Update the root hosting controller
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearanceFromString(appearance.rawValue)
                print("  ✓ Updated root hosting controller")
            }

            // Force a redraw
            UIApplication.shared.windows.forEach { $0.setNeedsDisplay() }
        }
    }

    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        guard style != statusBarState else { return }
        statusBarState = style
        rootViewController?
            .setNeedsStatusBarAppearanceUpdate()
    }

}




