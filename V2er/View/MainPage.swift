//
//  ContentView.swift
//  V2er
//
//  Created by Seth on 2020/5/23.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MainPage: View {
    @State var selecedTab = TabId.feed
    
    var body: some View {
        Group {
            switch selecedTab {
                case TabId.feed: HomePage()
                case TabId.explore: ExplorePage()
                case TabId.message: MessagePage()
                case TabId.me: MePage()
            }
        }
        .safeAreaInset(edge: .top) { TopBar(selectedTab: $selecedTab) }
        .safeAreaInset(edge: .bottom) { TabBar(selectedTab: $selecedTab) }
        .edgesIgnoringSafeArea([.bottom, .top])
    }
    
}


struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
