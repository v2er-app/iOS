//
//  Home.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedPage: BaseHomePageView {
    @EnvironmentObject private var store: Store
    @State private var isLoadingMore = false
    @State private var showOnlineStats = false
    var bindingState: Binding<FeedState> {
        $store.appState.feedState
    }
    var selecedTab: TabId

    var isSelected: Bool {
        selecedTab == .feed
    }

    private var navigationTitle: String {
        state.selectedTab.displayName()
    }

    var body: some View {
        contentView
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        withAnimation {
                            store.appState.feedState.scrollToTop = Int.random(in: 1...Int.max)
                        }
                    } label: {
                        Text("V2EX")
                            .font(AppFont.brandTitle)
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .onAppear {
                log("FeedPage.onAppear")
                if !state.hasLoadedOnce {
                    dispatch(FeedActions.FetchData.Start(autoLoad: true))
                    if AccountState.hasSignIn() {
                        Task {
                            await run(action: FeedActions.FetchOnlineStats.Start())
                            showOnlineStatsTemporarily()
                        }
                    }
                }
            }
    }

    @ViewBuilder
    private var filterMenu: some View {
        Menu {
            ForEach(Tab.allTabs, id: \.self) { tab in
                let tabNeedsLogin = tab.needsLogin() && !AccountState.hasSignIn()
                Button {
                    if tabNeedsLogin {
                        Toast.show("登录后才能查看「\(tab.displayName())」下的内容")
                    } else {
                        dispatch(FeedActions.SelectTab(tab: tab))
                    }
                } label: {
                    if state.selectedTab == tab {
                        Label(tab.displayName(), systemImage: "checkmark")
                    } else {
                        Text(tab.displayName())
                    }
                }
                .disabled(tabNeedsLogin)
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                Text(navigationTitle)
                    .font(AppFont.filterLabel)
                Image(systemName: "chevron.down")
                    .font(AppFont.filterChevron)
            }
            .foregroundColor(.primary)
            .accessibilityLabel("筛选: \(navigationTitle)")
        }
    }

    private func showOnlineStatsTemporarily() {
        guard state.onlineStats?.isValid() == true else { return }
        // Show online stats with animation
        withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
            showOnlineStats = true
        }
        // Auto dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                showOnlineStats = false
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollViewReader { proxy in
            List {
                // Feed Items
                ForEach(state.feedInfo.items) { item in
                    FeedItemView(data: item)
                        .cardScrollTransition()
                        .background {
                            NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                .opacity(0)
                        }
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
                }

                // Load More Indicator
                if state.hasMoreData && !state.feedInfo.items.isEmpty && state.selectedTab.supportsLoadMore() {
                    HStack {
                        Spacer()
                        if isLoadingMore {
                            ProgressView()
                        }
                        Spacer()
                    }
                    .frame(height: 50)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemGroupedBackground))
                    .onAppear {
                        guard !isLoadingMore && AccountState.hasSignIn() else { return }
                        isLoadingMore = true
                        Task {
                            await run(action: FeedActions.LoadMore.Start(state.willLoadPage))
                            await MainActor.run {
                                isLoadingMore = false
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .environment(\.defaultMinListRowHeight, 1)
            .onChange(of: state.scrollToTop) { _ in
                if let firstItem = state.feedInfo.items.first {
                    withAnimation {
                        proxy.scrollTo(firstItem.id, anchor: .top)
                    }
                }
            }
        }
        .refreshable {
            if AccountState.hasSignIn() {
                // Fetch online stats in parallel with feed data
                async let onlineStatsTask = run(action: FeedActions.FetchOnlineStats.Start())
                async let feedTask = run(action: FeedActions.FetchData.Start())
                await (onlineStatsTask, feedTask)
                showOnlineStatsTemporarily()
            }
        }
        .overlay(alignment: .top) {
            if showOnlineStats, let onlineStats = state.onlineStats, onlineStats.isValid() {
                OnlineStatsHeaderView(stats: onlineStats)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .overlay {
            if state.showProgressView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }

}

// Online Stats Header View
private struct OnlineStatsHeaderView: View {
    let stats: OnlineStatsInfo
    @State private var animatedOnlineCount: Int = 0

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)

            if #available(iOS 16.0, *) {
                Text("\(animatedOnlineCount) 人在线")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .contentTransition(.numericText())
            } else {
                Text("\(animatedOnlineCount) 人在线")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs + 2)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.top, Spacing.sm)
        .onAppear {
            if animatedOnlineCount == 0 && stats.onlineCount > 0 {
                animatedOnlineCount = stats.onlineCount
            }
        }
        .onChange(of: stats.onlineCount) { newValue in
            withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                animatedOnlineCount = newValue
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var selected = TabId.feed
    
    static var previews: some View {
        FeedPage(selecedTab: selected)
    }
}
