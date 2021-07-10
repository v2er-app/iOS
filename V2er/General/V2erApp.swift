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
        let coloredAppearance = UINavigationBarAppearance()
        let textColor = UIColor.black
        coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        
        let navAppearance = UINavigationBar.appearance()
        navAppearance.standardAppearance = coloredAppearance
        navAppearance.compactAppearance = coloredAppearance
        navAppearance.scrollEdgeAppearance = coloredAppearance
        navAppearance.tintColor = textColor
    }
    
    var body: some Scene {
        WindowGroup {
            MainPage()
        }
    }
}


