//
//  MessagePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import SwiftSoup
import Atributika

struct MessagePage: BaseHomePageView {
    @EnvironmentObject private var store: Store
    var bindingState: Binding<MessageState> {
        $store.appState.messageState
    }
    var selecedTab: TabId

    var isSelected: Bool {
        let selected = selecedTab == .message
        if selected && !state.hasLoadedOnce {
            dispatch(MessageActions.FetchStart(autoLoad: true))
        }
        return selected
    }
    
    @State private var isLoadingMore = false

    var body: some View {
        contentView
            .background(Color(.systemGroupedBackground))
            .navigationTitle("通知")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if !state.hasLoadedOnce {
                    dispatch(MessageActions.FetchStart(autoLoad: true))
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        List {
            ForEach(state.model.items) { item in
                MessageItemView(item: item)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemGroupedBackground))
            }

            // Load More Indicator
            if state.updatableState.hasMoreData && !state.model.items.isEmpty {
                HStack {
                    Spacer()
                    if isLoadingMore {
                        ProgressView()
                    }
                    Spacer()
                }
                .frame(height: 50)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
                .onAppear {
                    guard !isLoadingMore else { return }
                    isLoadingMore = true
                    Task {
                        await run(action: MessageActions.LoadMoreStart())
                        await MainActor.run {
                            isLoadingMore = false
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: MessageActions.FetchStart())
        }
        .overlay {
            if state.updatableState.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

struct MessageItemView: View {
    let item: MessageInfo.Item
    let quoteFont = Style.font(UIFont.prfered(.subheadline))
        .foregroundColor(Color.secondaryText.uiColor)
    @State private var navigateToRoute: AppRoute?

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Button {
                navigateToRoute = .userDetail(userId: item.username)
            } label: {
                AvatarView(url: item.avatar, size: 40)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Button {
                    navigateToRoute = .feedDetail(id: item.feedId)
                } label: {
                    Text(item.title)
                        .foregroundColor(Color(.label))
                        .greedyWidth(.leading)
                }
                RichText {
                    item.content
                        .rich(baseStyle: quoteFont)
                }
                .padding(Spacing.md)
                .background {
                    HStack(spacing: 0) {
                        Color.accentColor.opacity(0.8)
                            .frame(width: 3)
                        Color(.systemGray6)
                    }
                    .clipCorner(1.5, corners: [.topLeft, .bottomLeft])
                }
                .visibility(item.content.isEmpty ? .gone : .visible)
                if !item.time.isEmpty {
                    Text(item.time)
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .divider()
        .accessibilityElement(children: .combine)
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }

}

struct MessagePage_Previews: PreviewProvider {
    static var selected = TabId.message
    static var previews: some View {
        MessagePage(selecedTab: .message)
            .environmentObject(Store.shared)
    }
}
