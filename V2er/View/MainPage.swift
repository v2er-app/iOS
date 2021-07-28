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
        NavigationView {
            ZStack {
                NewsPage(selecedTab: $selecedTab)
                ExplorePage(selecedTab: $selecedTab)
                MessagePage(selecedTab: $selecedTab)
                MePage(selecedTab: $selecedTab)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(selectedTab: $selecedTab)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                TabBar(selectedTab: $selecedTab)
            }
            .ignoresSafeArea(.container)
            .navigationBarHidden(true)
            .buttonStyle(.plain)
        }
    }
    
}


struct MainPage_Previews: PreviewProvider {
//    @State static var selecedTab: TabId = TabId.me
    
    static var previews: some View {
        MainPage(selecedTab: .me)
    }
}
