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
                dispatch(MyRecentActions.LoadDataStart())
            }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(state.records ?? []) { item in
                    NavigationLink(value: AppRoute.feedDetail(id: item.id)) {
                        RecentItemView(data: item)
                            .background(Color(.secondarySystemGroupedBackground))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("最近浏览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecentItemView<Data: FeedItemProtocol>: View {
    let data: Data
    @State private var navigateToRoute: AppRoute?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                AvatarView(url: data.avatar)
                VStack(alignment: .leading, spacing: 5) {
                    Text(data.userName.safe)
                        .lineLimit(1)
                    Text(data.replyNum.safe)
                        .lineLimit(1)
                        .font(.footnote)
                        .foregroundColor(Color.accentColor)
                }
                Spacer()
                Button {
                    navigateToRoute = .tagDetail(tagId: data.nodeId.safe)
                } label: {
                    Text(data.nodeName.safe)
                        .nodeBadgeStyle()
                }
                .buttonStyle(.plain)
            }
            Text(data.title.safe)
                .greedyWidth(.leading)
                .lineLimit(2)
                .padding(.vertical, 3)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
        .divider()
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }
}


struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        MyRecentPage()
    }
}
