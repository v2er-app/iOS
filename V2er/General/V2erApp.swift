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
    
    init() {
        setupApperance()
    }
    
    private func setupApperance() {
        let navbarAppearance = UINavigationBarAppearance()
        let tintColor = UIColor.black
        navbarAppearance.titleTextAttributes = [.foregroundColor: tintColor]
        navbarAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
        
        let navAppearance = UINavigationBar.appearance()
        navAppearance.isTranslucent = true
        navAppearance.standardAppearance = navbarAppearance
        navAppearance.compactAppearance = navbarAppearance
        navAppearance.scrollEdgeAppearance = navbarAppearance
        navAppearance.tintColor = tintColor
    }
    
    var body: some Scene {
        WindowGroup {
            MainPage()
        }
    }
}


