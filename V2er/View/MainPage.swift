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
                TabView(selection: selectedTab) {
                    // Feed Tab
                    pageWithTopBar(
                        FeedPage(selecedTab: state.selectedTab)
                    )
                    .tabItem {
                        Label("最新", systemImage: "newspaper")
                    }
                    .tag(TabId.feed)

                    // Explore Tab
                    pageWithTopBar(
                        ExplorePage(selecedTab: state.selectedTab)
                    )
                    .tabItem {
                        Label("发现", systemImage: "safari")
                    }
                    .tag(TabId.explore)

                    // Message Tab
                    pageWithTopBar(
                        MessagePage(selecedTab: state.selectedTab)
                    )
                    .tabItem {
                        if unReadNums > 0 {
                            Label("通知", systemImage: "bell")
                                .badge(unReadNums)
                        } else {
                            Label("通知", systemImage: "bell")
                        }
                    }
                    .tag(TabId.message)

                    // Me Tab
                    pageWithTopBar(
                        MePage(selecedTab: state.selectedTab)
                    )
                    .tabItem {
                        Label("我", systemImage: "person")
                    }
                    .tag(TabId.me)
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
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func pageWithTopBar<Content: View>(_ content: Content) -> some View {
        VStack(spacing: 0) {
            TopBar(selectedTab: state.selectedTab)
            content
        }
        .ignoresSafeArea(.container, edges: .top)
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
