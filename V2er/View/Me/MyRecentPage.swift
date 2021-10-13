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
                ForEach(state.records ?? []) { item in
                    NavigationLink {
                        FeedDetailPage(id: item.id)
                    } label: {
                        RecentItemView(data: item)
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

struct RecentItemView<Data: FeedItemProtocol>: View {
    let data: Data

    var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    NavigationLink(destination: UserDetailPage(userId: data.userName)) {
                        AvatarView(url: data.avatar)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(data.userName.safe)
                            .lineLimit(1)
                            .font(.body)
                        Text(data.replyNum.safe)
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundColor(Color.tintColor)
                    }
                    Spacer()
                    NodeView(id: data.nodeId.safe, name: data.nodeName.safe)
                }
                Text(data.title.safe)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                    .padding(.vertical, 3)
            }
            .padding(12)
            .background(Color.almostClear)
            .divider()
    }
}


struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        MyRecentPage()
    }
}
