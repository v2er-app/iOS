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
        // Configure TabBar appearance for better contrast in both light and dark modes
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        // Set tint color for selected items
        // Light Mode: deep/dark color (from Color.tintColor)
        // Dark Mode: white (from Color.tintColor)
        UITabBar.appearance().tintColor = UIColor(Color.tintColor)

        // Set color for unselected items with subtle difference from selected
        // Light mode: selected = dark color, unselected = slightly lighter dark color (60% opacity)
        // Dark mode: selected = white, unselected = slightly dimmed white (60% opacity)
        let unselectedColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Dark mode: slightly dimmed white (60% opacity for subtle difference)
                return UIColor.white.withAlphaComponent(0.6)
            default:
                // Light mode: slightly lighter dark color (60% opacity for subtle difference)
                return UIColor.black.withAlphaComponent(0.6)
            }
        }
        UITabBar.appearance().unselectedItemTintColor = unselectedColor

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
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
        NavigationView {
            ZStack {
                TabView(selection: tabSelection) {
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
            .onReceive(tabReselectionPublisher) { tappedTab in
                // Dispatch action for all tab taps (including same-tab taps)
                dispatch(TabbarClickAction(selectedTab: tappedTab))
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
