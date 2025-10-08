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

    var bindingState: Binding<GlobalState> {
        $store.appState.globalState
    }
    var selectedTab: Binding<TabId> {
        bindingState.selectedTab
    }

    var unReadNums: Int {
        store.appState.feedState.feedInfo.unReadNums
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Main content pages
                ZStack {
                    FeedPage(selecedTab: state.selectedTab)
                    ExplorePage(selecedTab: state.selectedTab)
                    MessagePage(selecedTab: state.selectedTab)
                    MePage(selecedTab: state.selectedTab)
                }

                // Filter menu overlay - only render when needed
                if state.selectedTab == .feed && store.appState.feedState.showFilterMenu {
                    FilterMenuView(
                        selectedTab: store.appState.feedState.selectedTab,
                        isShowing: true,
                        onTabSelected: { tab in
                            dispatch(FeedActions.SelectTab(tab: tab))
                        },
                        onDismiss: {
                            dispatch(FeedActions.ToggleFilterMenu())
                        }
                    )
                    .zIndex(1000)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(selectedTab: state.selectedTab)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                TabBar(unReadNums)
            }
            .ignoresSafeArea(.container)
            .navigationBarHidden(true)
        }
    }
    
}


//struct MainPage_Previews: PreviewProvider {
////    @State static var selecedTab: TabId = TabId.me
//
//    static var previews: some View {
//        MainPage()
//            .environmentObject(Store.shared)
//    }
//}
