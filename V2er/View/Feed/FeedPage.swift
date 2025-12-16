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

    var body: some View {
        contentView
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

    private func showOnlineStatsTemporarily() {
        guard state.onlineStats?.isValid() == true else { return }
        // Show online stats with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            showOnlineStats = true
        }
        // Auto dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showOnlineStats = false
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        List {
            // Feed Items
            ForEach(state.feedInfo.items) { item in
                ZStack {
                    // Hidden NavigationLink to avoid disclosure indicator
                    NavigationLink(destination: FeedDetailPage(initData: item)) {
                        EmptyView()
                    }
                    .opacity(0)

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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.itemBg.opacity(0.95))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.top, 8)
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
