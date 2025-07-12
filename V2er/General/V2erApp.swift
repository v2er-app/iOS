//
//  App.swift
//  V2er
//
//  Created by Seth on 2020/7/1.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

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
                    .preferredColorScheme(store.appState.settingState.appearance.colorScheme)
                    .onAppear {
                        updateNavigationBarAppearance(for: store.appState.settingState.appearance)
                    }
                    .onChange(of: store.appState.settingState.appearance) { newValue in
                        updateNavigationBarAppearance(for: newValue)
                    }
            }
        }
    }
    
    private func updateNavigationBarAppearance(for appearance: AppearanceMode) {
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
    }

    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        guard style != statusBarState else { return }
        statusBarState = style
        rootViewController?
            .setNeedsStatusBarAppearanceUpdate()
    }

}




