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
    var bindingState: Binding<FeedState> {
        $store.appState.feedState
    }
    var selecedTab: TabId

    var isSelected: Bool {
        let selected = selecedTab == .feed
        if selected && !state.hasLoadedOnce {
            dispatch(FeedActions.FetchData.Start(autoLoad: true))
        }
        return selected
    }

    var body: some View {
        contentView
            .hide(!isSelected)
            .onAppear {
                log("FeedPage.onAppear")
            }
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(spacing: 0) {
            ForEach(state.feedInfo.items) { item in
                NavigationLink(destination: FeedDetailPage(initData: item)) {
                    FeedItemView(data: item)
                }
            }
        }
        .updatable(autoRefresh: state.showProgressView, hasMoreData: state.hasMoreData, scrollTop(tab: .feed)) {
            await run(action: FeedActions.FetchData.Start())
        } loadMore: {
            await run(action: FeedActions.LoadMore.Start(state.willLoadPage))
        }
        .background(Color.bgColor)
    }

}

struct HomePage_Previews: PreviewProvider {
    static var selected = TabId.feed
    
    static var previews: some View {
        FeedPage(selecedTab: selected)
    }
}
