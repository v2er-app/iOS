//
//  SpecailCarePage.swift
//  SpecailCarePage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct MyFollowPage: StateView {
    @EnvironmentObject private var store: Store

    var bindingState: Binding<MyFollowState> {
        return $store.appState.myFollowState
    }

    var body: some View {
        contentView
            .updatable(state.updatableState) {
                await run(action: MyFollowActions.FetchStart(autoLoad: false))
            } loadMore: {
                await run(action: MyFollowActions.LoadMoreStart())
            }
            .onAppear {
                dispatch(MyFollowActions.FetchStart(autoLoad: !state.updatableState.hasLoadedOnce))
            }
            .navBar("我的关注")
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(spacing: 0) {
            ForEach(state.model?.items ?? []) { item in
                NavigationLink {
                    FeedDetailPage(id: item.id)
                } label: {
                    FeedItemView(data: item)
                }
            }
        }
    }
}

struct SpecailCarePage_Previews: PreviewProvider {
    static var previews: some View {
        MyFollowPage()
    }
}
