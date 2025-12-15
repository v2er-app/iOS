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
    var bindingState: Binding<FeedState> {
        $store.appState.feedState
    }
    var selecedTab: TabId

    var isSelected: Bool {
        selecedTab == .feed
    }

    var body: some View {
        contentView
            .onAppear {
                log("FeedPage.onAppear")
                if !state.hasLoadedOnce {
                    dispatch(FeedActions.FetchData.Start(autoLoad: true))
                    if AccountState.hasSignIn() {
                        Task { await run(action: FeedActions.FetchOnlineStats.Start()) }
                    }
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        List {
            // Online Stats Header
            if let onlineStats = state.onlineStats, onlineStats.isValid() {
                OnlineStatsHeaderView(stats: onlineStats)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.bgColor)
            }

            // Feed Items
            ForEach(state.feedInfo.items) { item in
                NavigationLink(destination: FeedDetailPage(initData: item)) {
                    FeedItemView(data: item)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.itemBg)
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
                .listRowBackground(Color.bgColor)
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
        .background(Color.bgColor)
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            if AccountState.hasSignIn() {
                // Fetch online stats in parallel with feed data
                Task { await run(action: FeedActions.FetchOnlineStats.Start()) }
                await run(action: FeedActions.FetchData.Start())
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
            Spacer()
            Circle()
                .fill(Color.hex(0x52bf1c))
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
            Spacer()
        }
        .padding(.vertical, 8)
        .onAppear {
            if animatedOnlineCount == 0 && stats.onlineCount > 0 {
                animatedOnlineCount = stats.onlineCount
            }
        }
        .onChange(of: stats.onlineCount) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
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
