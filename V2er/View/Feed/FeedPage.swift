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
    var state: FeedState {
        store.appState.feedState
    }
    var selecedTab: TabId

    var isSelected: Bool {
        let selected = selecedTab == .feed
        if selected && !state.hasLoadedOnce {
            dispatch(action: FeedActions.FetchData.Start(autoLoad: true))
        }
        return selected
    }

    var body: some View {
        contentView
            .hide(!isSelected)
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
        .background(Color.pageLight)
        .updatable(autoRefresh: state.showProgressView, hasMoreData: state.hasMoreData, scrollTop(tab: .feed)) {
            await run(action: FeedActions.FetchData.Start())
        } loadMore: {
            await run(action: FeedActions.LoadMore.Start(state.willLoadPage))
        }
    }

}


//private func fetchData() async -> [String] {
//    await withCheckedContinuation { continuation in
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2 ) {
//            let persons = [
//                "new Person 1",
//                "new Person 2",
//                "new Person 3",
//                "new Person 4"
//            ]
//            continuation.resume(returning: persons)
//        }
//    }
//}

struct HomePage_Previews: PreviewProvider {
    static var selected = TabId.feed
    
    static var previews: some View {
        FeedPage(selecedTab: selected)
    }
}
