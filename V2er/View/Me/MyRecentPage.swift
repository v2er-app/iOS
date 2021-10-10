//
//  HistoryPage.swift
//  HistoryPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct MyRecentPage: StateView {
    @EnvironmentObject private var store: Store

    var bindingState: Binding<MyRecentState> {
        return $store.appState.myRecentState
    }

    var body: some View {
        contentView
            .onAppear {
                dispatch(action: MyRecentActions.LoadDataStart())
            }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
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
        .safeAreaInset(edge: .top, spacing: 0) {
            NavbarView {
                Text("最近浏览")
                    .font(.headline)
            }
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
    }
}

struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        MyRecentPage()
    }
}
