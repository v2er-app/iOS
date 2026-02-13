//
//  Home.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct FeedPage: BaseHomePageView {
    @ObservedObject private var store = Store.shared
    @State private var isLoadingMore = false
    @State private var isRefreshing = false
    @State private var showOnlineStats = false
    #if os(macOS)
    @State private var macToolbarWidth: CGFloat = 350
    #endif
    var bindingState: Binding<FeedState> {
        $store.appState.feedState
    }
    var selecedTab: TabId
    var onSelectFeed: ((String) -> Void)? = nil
    var iPadSelectedFeedId: String? = nil

    var isSelected: Bool {
        selecedTab == .feed
    }

    private var navigationTitle: String {
        state.selectedTab.displayName()
    }

    private var brandTitleButton: some View {
        Button {
            withAnimation {
                store.appState.feedState.scrollToTop = Int.random(in: 1...Int.max)
            }
        } label: {
            BrandTitleView(isRefreshing: isRefreshing)
        }
    }

    var body: some View {
        contentView
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    brandTitleButton
                }
                ToolbarItem(placement: .automatic) {
                    filterMenu
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack {
                        brandTitleButton
                            .padding(.leading, Spacing.sm)
                        Spacer()
                        filterMenu
                            .padding(.trailing, Spacing.md)
                    }
                    .frame(width: macToolbarWidth - Spacing.md)
                }
            }
            .onAppear {
                for delay in [0.1, 0.5] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        for window in NSApp.windows {
                            window.toolbar?.items.forEach { $0.isBordered = false }
                        }
                    }
                }
            }
            #endif
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
            #if os(macOS)
            (Text(navigationTitle).font(AppFont.filterLabel) + Text("  \(Image(systemName: "chevron.down"))").font(AppFont.filterChevron))
                .foregroundColor(.primary)
                .accessibilityLabel("筛选: \(navigationTitle)")
            #else
            HStack(spacing: Spacing.xs) {
                Text(navigationTitle)
                    .font(AppFont.filterLabel)
                Image(systemName: "chevron.down")
                    .font(AppFont.filterChevron)
            }
            .foregroundColor(.primary)
            .accessibilityLabel("筛选: \(navigationTitle)")
            #endif
        }
        #if os(macOS)
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        #endif
        .tint(.primary)
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
                    if let onSelectFeed {
                        FeedItemView(data: item)
                            .cardScrollTransition()
                            .opacity(iPadSelectedFeedId == item.id ? 0.5 : 1.0)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelectFeed(item.id) }
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemGroupedBackground))
                    } else {
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
        #if os(macOS)
        .background(GeometryReader { geo in
            Color.clear.onAppear { macToolbarWidth = geo.size.width }
                .onChange(of: geo.size.width) { macToolbarWidth = $1 }
        })
        #endif
        .refreshable {
            if AccountState.hasSignIn() {
                isRefreshing = true
                defer { isRefreshing = false }
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
                List {
                    FeedPlaceholder()
                        .redacted(reason: .placeholder)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .environment(\.defaultMinListRowHeight, 1)
                .scrollDisabled(true)
                .transition(.opacity.animation(.easeOut(duration: 0.4)))
            }
        }
    }

}

// Brand Title: default "V2er", shows "V2EX" during refresh
private struct BrandTitleView: View {
    var isRefreshing: Bool

    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            Text(isRefreshing ? "V2EX" : "V2ER")
                .font(AppFont.brandTitle)
                .foregroundColor(.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.5), value: isRefreshing)
        } else {
            Text("V2er")
                .font(AppFont.brandTitle)
                .foregroundColor(.primary)
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

            if #available(iOS 16.0, macOS 13.0, *) {
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
