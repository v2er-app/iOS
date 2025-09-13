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
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AppearanceDidChange"),
            object: nil,
            queue: .main
        ) { notification in
            if let appearance = notification.object as? AppearanceMode {
                print("📱 Received appearance change notification: \(appearance.rawValue)")
                self.updateAppearance(appearance)
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
            ZStack {
                // Hidden view to trigger redraws
                Color.clear
                    .frame(width: 0, height: 0)
                    .id(store.appState.settingState.appearance)

                RootView {
                    RootHostView()
                        .environmentObject(store)
                }
            }
            .preferredColorScheme(store.appState.settingState.appearance.colorScheme)
            .environmentObject(store)
            .onAppear {
                updateAppearance(store.appState.settingState.appearance)
            }
            .onChange(of: store.appState.settingState.appearance) { newValue in
                updateAppearance(newValue)
            }
        }
    }

    private func updateAppearance(_ appearance: AppearanceMode) {
        updateNavigationBarAppearance(for: appearance)
        updateWindowInterfaceStyle(for: appearance)
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
    
    private func updateWindowInterfaceStyle(for appearance: AppearanceMode) {
        DispatchQueue.main.async {
            // Get all windows and update their interface style
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

            let style: UIUserInterfaceStyle
            switch appearance {
            case .light:
                style = .light
            case .dark:
                style = .dark
            case .system:
                style = .unspecified
            }

            // Update all windows in the scene
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }

            // Also update the stored window if available
            if let window = V2erApp.window {
                window.overrideUserInterfaceStyle = style
            }

            // Update the root hosting controller
            if let rootHostingController = V2erApp.rootViewController as? RootHostingController<RootHostView> {
                rootHostingController.applyAppearance(appearance)
            }
        }
    }

    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        guard style != statusBarState else { return }
        statusBarState = style
        rootViewController?
            .setNeedsStatusBarAppearanceUpdate()
    }

}




