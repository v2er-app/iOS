//
//  StarPage.swift
//  StarPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct MyFavoritePage: StateView {
    @EnvironmentObject private var store: Store
    @State private var selectedTab: Int = 0
    @State private var isFeedLoadingMore = false

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
        .tabViewStyle(.page)
        .debug()
        .navigationTitle("收藏")
        .navigationBarTitleDisplayMode(.inline)
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
                ZStack {
                    NavigationLink(destination: FeedDetailPage(id: item.id)) {
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
                .listRowBackground(Color.bgColor)
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
        .background(Color.bgColor)
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
                    ZStack {
                        NavigationLink(destination: TagDetailPage(tagId: item.id)) {
                            EmptyView()
                        }
                        .opacity(0)

                        VStack {
                            AvatarView(url: item.img)
                            Text(item.name)
                            Text(item.topicNum)
                                .font(.footnote)
                        }
                        .lineLimit(1)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.itemBg)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.bgColor)
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
    }

}

struct StarPage_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoritePage()
            .environmentObject(Store.shared)
    }
}
