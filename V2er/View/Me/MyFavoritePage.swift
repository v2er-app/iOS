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

    var bindingState: Binding<MyFavoriteState> {
        return $store.appState.myFavoriteState
    }

    var body: some View {
        contentView
            .navigatable()
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
        .padding(.horizontal, 10)
        .debug()
        .safeAreaInset(edge: .top, spacing: 0) { navBar }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var navBar: some View {
        NavbarTitleView {
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

    @ViewBuilder
    private var feedView: some View {
        LazyVStack(spacing: 0) {
            ForEach(state.feedState.model?.items ?? []) { item in
                NavigationLink {
                    FeedDetailPage(id: item.id)
                } label: {
                    FeedItemView(data: item)
                }
            }
        }
        .padding(.top, 30)
        .onAppear {
            dispatch(MyFavoriteActions.FetchFeedStart(autoLoad: !state.feedState.updatable.hasLoadedOnce))
        }
        .updatable(state.feedState.updatable) {
            await run(action: MyFavoriteActions.FetchFeedStart())
        } loadMore: {
            await run(action: MyFavoriteActions.LoadMoreFeedStart())
        }
    }

    @ViewBuilder
    private var nodeView: some View {
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
        LazyVGrid(columns: columns) {
            ForEach(state.nodeState.model?.items ?? []) { item in
                NavigationLink {
                    TagDetailPage(tagId: item.id)
                } label: {
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
        .padding(.top, 30)
        .onAppear {
            dispatch(MyFavoriteActions.FetchNodeStart(autoLoad: !state.nodeState.updatable.hasLoadedOnce))
        }
        .updatable(state.nodeState.updatable) {
            await run(action: MyFavoriteActions.FetchNodeStart())
        }
    }

}

struct StarPage_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoritePage()
            .environmentObject(Store.shared)
    }
}
