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
    @ObservedObject private var store = Store.shared
    @State private var tabReselectionPublisher = PassthroughSubject<TabId, Never>()
    @ObservedObject private var otherAppsManager = OtherAppsManager.shared
    @ObservedObject private var accountManager = AccountManager.shared

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
        #if os(iOS)
        // Configure unselected item color using UITabBar.appearance()
        // Selected color is controlled by .accentColor() modifier on TabView
        let unselectedColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            default:
                return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0)
            }
        }

        UITabBar.appearance().unselectedItemTintColor = unselectedColor
        #endif
    }

    // Intermediate binding that publishes tab-tap events (for scroll-to-top)
    private var tabSelection: Binding<TabId> {
        Binding(
            get: { selectedTab.wrappedValue },
            set: { newValue in
                tabReselectionPublisher.send(newValue)
                selectedTab.wrappedValue = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            // Feed Tab
            AdaptiveTabContent {
                iPadFeedSplitView(selecedTab: state.selectedTab)
            } compactContent: {
                NavigationStack {
                    FeedPage(selecedTab: state.selectedTab)
                        .navigationDestination(for: AppRoute.self) { $0.destination() }
                }
            }
            .tabItem { Label("最新", systemImage: "newspaper") }
            .tag(TabId.feed)

            // Explore Tab
            AdaptiveTabContent {
                iPadTabSplitView(placeholderIcon: "magnifyingglass", placeholderText: "选择一个主题") {
                    ExplorePage(selecedTab: state.selectedTab)
                }
            } compactContent: {
                NavigationStack {
                    ExplorePage(selecedTab: state.selectedTab)
                        .navigationDestination(for: AppRoute.self) { $0.destination() }
                }
            }
            .tabItem { Label("搜索", systemImage: "magnifyingglass") }
            .tag(TabId.explore)

            // Message Tab
            AdaptiveTabContent {
                iPadTabSplitView(placeholderIcon: "bell", placeholderText: "选择一条通知") {
                    MessagePage(selecedTab: state.selectedTab)
                }
            } compactContent: {
                NavigationStack {
                    MessagePage(selecedTab: state.selectedTab)
                        .navigationDestination(for: AppRoute.self) { $0.destination() }
                }
            }
            .badge(unReadNums > 0 ? unReadNums : 0)
            .tabItem { Label("通知", systemImage: "bell") }
            .tag(TabId.message)

            // Me Tab
            AdaptiveTabContent {
                iPadTabSplitView(placeholderIcon: "person", placeholderText: "选择一个项目") {
                    MePage(selecedTab: state.selectedTab)
                }
            } compactContent: {
                NavigationStack {
                    MePage(selecedTab: state.selectedTab)
                        .navigationDestination(for: AppRoute.self) { $0.destination() }
                }
            }
            .badge(otherAppsManager.showOtherAppsBadge ? 1 : 0)
            .tabItem { Label("我", systemImage: "person") }
            .tag(TabId.me)
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color("TintColor"))
        #if os(iOS)
        .background(
            TabBarContextMenuAttacher(
                accountManager: accountManager,
                onSwitch: { username in
                    accountManager.switchTo(username: username)
                },
                onAddAccount: {
                    accountManager.archiveCurrentAccountCookies()
                    APIService.shared.clearCookie()
                    dispatch(LoginActions.ShowLoginPageAction())
                },
                onManageAccounts: {
                    selectedTab.wrappedValue = .me
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        accountManager.showSwitcher = true
                    }
                }
            )
        )
        #endif
        .onReceive(tabReselectionPublisher) { tappedTab in
            dispatch(TabbarClickAction(selectedTab: tappedTab))
        }
    }
}
