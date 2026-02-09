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
            LazyVStack(spacing: Spacing.xs) {
                ForEach(state.records ?? []) { item in
                    NavigationLink(value: AppRoute.feedDetail(id: item.id)) {
                        RecentItemView(data: item)
                    }
                    .buttonStyle(.plain)
                    .cardScrollTransition()
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("最近浏览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecentItemView<Data: FeedItemProtocol>: View {
    let data: Data
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
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
                    navigate(to: .tagDetail(tagId: data.nodeId.safe))
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
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .contentShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }

    private func navigate(to route: AppRoute) {
        if let detailRoute = iPadDetailRoute {
            detailRoute.wrappedValue = route
        } else {
            navigateToRoute = route
        }
    }
}


struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        MyRecentPage()
    }
}
