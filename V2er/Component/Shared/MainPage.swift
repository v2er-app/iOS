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
        ZStack(alignment: .bottom) {
            switch selectedId {
            case TabId.feed: HomePage()
            case TabId.explore: ExplorePage()
            case TabId.message: MessagePage()
            case TabId.me: MePage()
            }
            TabBar(selectedId: $selectedId)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
