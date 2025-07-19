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
            // Check if user is not logged in, load mock data for UI testing
            if !AccountState.hasSignIn() {
                dispatch(FeedActions.LoadMockData())
            } else {
                dispatch(FeedActions.FetchData.Start(autoLoad: true))
            }
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
        VStack(spacing: 0) {
            // Show debug banner when using mock data
            if !AccountState.hasSignIn() && state.hasLoadedOnce {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Debug Mode: Showing mock data (not logged in)")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.dynamic(light: Color.orange.opacity(0.1), dark: Color.orange.opacity(0.2)))
                .cornerRadius(8)
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            
            LazyVStack(spacing: 0) {
                ForEach(state.feedInfo.items) { item in
                    NavigationLink(destination: FeedDetailPage(initData: item)) {
                        FeedItemView(data: item)
                    }
                }
            }
        }
        .updatable(autoRefresh: state.showProgressView, hasMoreData: state.hasMoreData, scrollTop(tab: .feed)) {
            if AccountState.hasSignIn() {
                await run(action: FeedActions.FetchData.Start())
            }
        } loadMore: {
            if AccountState.hasSignIn() {
                await run(action: FeedActions.LoadMore.Start(state.willLoadPage))
            }
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
