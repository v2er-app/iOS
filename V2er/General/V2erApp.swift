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
    
    init() {
        setupApperance()
    }
    
    private func setupApperance() {
        
//        let tintColor = UIColor(named: "indictor")
        let tintColor = UIColor.black

//        UINavigationBar.appearance().largeTitleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: tintColor!]
//
//        UINavigationBar.appearance().titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: tintColor!]
//
//        UIBarButtonItem.appearance().setTitleTextAttributes([
//            NSAttributedString.Key.foregroundColor: tintColor], for: .normal)
        UIBarButtonItem.appearance().tintColor = tintColor
        
        UIWindow.appearance().tintColor = .black
    }
    
    var body: some Scene {
        WindowGroup {
            MainPage()
        }
    }
}
