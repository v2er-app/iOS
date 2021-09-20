//
//  ContentView.swift
//  V2er
//
//  Created by Seth on 2020/5/23.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MainPage: StateView {
    @EnvironmentObject private var store: Store
    var state: MainPageState {
        store.appState.mainPageState
    }
    var selectedTab: Binding<TabId> {
        $store.appState.mainPageState.selectedTab
    }

    var body: some View {
        NavigationView {
            ZStack {
                FeedPage(selecedTab: state.selectedTab)
                ExplorePage(selecedTab: state.selectedTab)
                MessagePage(selecedTab: state.selectedTab)
                MePage(selecedTab: state.selectedTab)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(selectedTab: state.selectedTab)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                TabBar(selectedTab: selectedTab)
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
        MainPage()
            .environmentObject(Store.shared)
    }
}
