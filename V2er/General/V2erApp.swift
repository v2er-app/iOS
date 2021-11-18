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

    init() {
        setupApperance()
    }
    
    private func setupApperance() {
        let navbarAppearance = UINavigationBarAppearance()
        let tintColor = UIColor.black
        navbarAppearance.titleTextAttributes = [.foregroundColor: tintColor]
        navbarAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
        navbarAppearance.backgroundColor = .clear
        
        let navAppearance = UINavigationBar.appearance()
        navAppearance.isTranslucent = true
        navAppearance.standardAppearance = navbarAppearance
        navAppearance.compactAppearance = navbarAppearance
        navAppearance.scrollEdgeAppearance = navbarAppearance
        navAppearance.backgroundColor = .clear
        navAppearance.tintColor = tintColor
    }
    
    var body: some Scene {
        WindowGroup {
            RootView {
                RootHostView()
                    .environmentObject(Store.shared)
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




