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
    #if os(iOS)
    public static let deviceType = UIDevice().type
    public static var rootViewController: UIViewController?
    public static var statusBarState: UIStatusBarStyle = .darkContent
    public static var window: UIWindow?
    #endif

    @StateObject private var store = Store.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if os(iOS)
        setupApperance()
        NotificationManager.shared.registerBackgroundTask()
        #endif
    }

    #if os(iOS)
    private func setupApperance() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.isTranslucent = true
    }
    #endif

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            RootView {
                RootHostView()
                    .environmentObject(store)
            }
            .onAppear {
                updateAppearance(store.appState.settingState.appearance)
                OtherAppsManager.shared.recordLaunch()
                OtherAppsManager.shared.refreshBadge()
            }
            .onChange(of: store.appState.settingState.appearance) { newValue in
                updateAppearance(newValue)
            }
            .onChange(of: scenePhase) { phase in
                if phase == .background {
                    AccountManager.shared.refreshArchivedCookiesForActiveAccount()
                }
            }
            #else
            RootHostView()
                .environmentObject(store)
                .macOSLifecycle()
                .onAppear {
                    OtherAppsManager.shared.recordLaunch()
                    OtherAppsManager.shared.refreshBadge()
                }
            #endif
        }
        #if os(macOS)
        .commands {
            V2erCommands()
        }
        #endif
    }

    #if os(iOS)
    private func updateAppearance(_ appearance: AppearanceMode) {
        Self.updateNavigationBarAppearance()
        updateWindowInterfaceStyle(for: appearance)
        Self.changeStatusBarStyle(Self.defaultStatusBarStyle())
    }

    static func updateAppearanceStatic(_ appearance: AppearanceMode) {
        updateNavigationBarAppearance()
        updateWindowInterfaceStyleStatic(for: appearance)
    }

    private static func updateNavigationBarAppearance() {
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

            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style
                    }
                }
            }
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
            }
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearanceFromString(appearance.rawValue)
            }
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { $0.setNeedsDisplay() }
                }
            }
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

            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style
                    }
                }
            }
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
            }
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearanceFromString(appearance.rawValue)
            }
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { $0.setNeedsDisplay() }
                }
            }
        }
    }

    static func defaultStatusBarStyle() -> UIStatusBarStyle {
        let isDark: Bool
        let appearance = Store.shared.appState.settingState.appearance
        switch appearance {
        case .dark:
            isDark = true
        case .light:
            isDark = false
        case .system:
            isDark = UITraitCollection.current.userInterfaceStyle == .dark
        }
        return isDark ? .lightContent : .darkContent
    }

    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        guard style != statusBarState else { return }
        statusBarState = style
        rootViewController?
            .setNeedsStatusBarAppearanceUpdate()
    }
    #endif
}
