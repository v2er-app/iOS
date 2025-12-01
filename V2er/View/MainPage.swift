//
//  ContentView.swift
//  V2er
//
//  Created by Seth on 2020/5/23.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import Combine

struct MainPage: StateView {
    @EnvironmentObject private var store: Store
    @State private var tabReselectionPublisher = PassthroughSubject<TabId, Never>()

    var bindingState: Binding<GlobalState> {
        $store.appState.globalState
    }
    var selectedTab: Binding<TabId> {
        bindingState.selectedTab
    }

    var unReadNums: Int {
        store.appState.feedState.feedInfo.unReadNums
    }

    init() {
        // Configure unselected item color using UITabBar.appearance()
        // Selected color is controlled by .accentColor() modifier on TabView
        let unselectedColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Dark mode: dim gray (60% white)
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            default:
                // Light mode: very light gray (78% gray - very subtle)
                return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0)
            }
        }

        UITabBar.appearance().unselectedItemTintColor = unselectedColor
    }

    // Create an intermediate binding that captures all tab selections
    // This is the proper SwiftUI way to detect same-tab taps without UIKit
    private var tabSelection: Binding<TabId> {
        Binding(
            get: { selectedTab.wrappedValue },
            set: { newValue in
                // Publish the tap event before changing the value
                // This allows us to detect same-tab taps
                tabReselectionPublisher.send(newValue)

                // Always update the selection to maintain consistency
                selectedTab.wrappedValue = newValue
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // TopBar outside TabView to ensure it updates immediately
                    TopBar(selectedTab: state.selectedTab, feedFilterTab: store.appState.feedState.selectedTab)

                    TabView(selection: tabSelection) {
                        // Feed Tab
                        FeedPage(selecedTab: state.selectedTab)
                            .tabItem {
                                Label("最新", systemImage: "newspaper")
                            }
                            .tag(TabId.feed)

                        // Explore Tab
                        ExplorePage(selecedTab: state.selectedTab)
                            .tabItem {
                                Label("发现", systemImage: "safari")
                            }
                            .tag(TabId.explore)

                        // Message Tab
                        MessagePage(selecedTab: state.selectedTab)
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
                        MePage(selecedTab: state.selectedTab)
                            .tabItem {
                                Label("我", systemImage: "person")
                            }
                            .tag(TabId.me)
                    }
                    .accentColor(Color.primary)  // This controls the selected icon color in TabView
                }
                .ignoresSafeArea(.container, edges: .top)

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
            .onReceive(tabReselectionPublisher) { tappedTab in
                // Dispatch action for all tab taps (including same-tab taps)
                dispatch(TabbarClickAction(selectedTab: tappedTab))
            }
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
