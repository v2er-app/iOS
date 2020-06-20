//
//  ContentView.swift
//  V2er
//
//  Created by Seth on 2020/5/23.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MainPage: View {
    @State var selectedId = TabId.feed
    
    var body: some View {
        ZStack {
            Color(.clear)
                .background(VEBlur())
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                containedView()
                Spacer()
                Divider().frame(height: 0.1)
                TabBar(selectedId: $selectedId)
            }
        }
    }
    
    func containedView() -> some View {
        switch selectedId {
        case TabId.feed: return AnyView(HomePage())
        case TabId.explore: return AnyView(ExplorePage())
        case TabId.message: return AnyView(MessagePage())
        case TabId.me: return AnyView(AccountPage())
       }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
