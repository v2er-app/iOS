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
    
    public static let viewController: UIHostingController = UIHostingController(rootView: Text(""))
    
    public static func measureSize(view: Text) -> CGSize {
        viewController.rootView = view
        return viewController.view.intrinsicContentSize
    }

    
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
            MainPage()
                .environmentObject(Store.shared)
                .buttonStyle(.plain)
//                .navigationBarTitle("")
//                .navigationBarHidden(true)
//                .ignoresSafeArea(.container)
        }
    }

}


