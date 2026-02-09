//
//  StarPage.swift
//  StarPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct MyFavoritePage: StateView {
    @ObservedObject private var store = Store.shared
    @State private var selectedTab: Int = 0
    @State private var isFeedLoadingMore = false
    @State private var navigateToNode: AppRoute?

    var bindingState: Binding<MyFavoriteState> {
        return $store.appState.myFavoriteState
    }

    var body: some View {
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        TabView(selection: $selectedTab) {
            feedView
                .tag(0)
            nodeView
                .tag(1)
        }
        #if os(iOS)
        .tabViewStyle(.page)
        #endif
        .navigationTitle("收藏")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("收藏", selection: $selectedTab) {
                    Text("主题")
                        .tag(0)
                    Text("节点")
                        .tag(1)
                }
                .font(.headline)
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
            }
        }
    }

    @ViewBuilder
    private var feedView: some View {
        List {
            ForEach(state.feedState.model?.items ?? []) { item in
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
            if state.feedState.updatable.hasMoreData && !(state.feedState.model?.items ?? []).isEmpty {
                HStack {
                    Spacer()
                    if isFeedLoadingMore {
                        ProgressView()
                    }
                    Spacer()
                }
                .frame(height: 50)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
                .onAppear {
                    guard !isFeedLoadingMore else { return }
                    isFeedLoadingMore = true
                    Task {
                        await run(action: MyFavoriteActions.LoadMoreFeedStart())
                        await MainActor.run {
                            isFeedLoadingMore = false
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: MyFavoriteActions.FetchFeedStart())
        }
        .overlay {
            if state.feedState.updatable.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            dispatch(MyFavoriteActions.FetchFeedStart(autoLoad: !state.feedState.updatable.hasLoadedOnce))
        }
    }

    @ViewBuilder
    private var nodeView: some View {
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
        List {
            LazyVGrid(columns: columns) {
                ForEach(state.nodeState.model?.items ?? []) { item in
                    Button {
                        navigateToNode = .tagDetail(tagId: item.id)
                    } label: {
                        VStack {
                            AvatarView(url: item.img)
                            Text(item.name)
                            Text(item.topicNum)
                                .font(.footnote)
                        }
                        .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listRowInsets(EdgeInsets(top: Spacing.md, leading: Spacing.md, bottom: Spacing.md, trailing: Spacing.md))
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.secondarySystemGroupedBackground))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: MyFavoriteActions.FetchNodeStart())
        }
        .overlay {
            if state.nodeState.updatable.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            dispatch(MyFavoriteActions.FetchNodeStart(autoLoad: !state.nodeState.updatable.hasLoadedOnce))
        }
        .navigationDestination(item: $navigateToNode) { route in
            route.destination()
        }
    }

}

struct StarPage_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoritePage()
            .environmentObject(Store.shared)
    }
}
