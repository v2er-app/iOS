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
            .background(Color.bgColor)
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
                    .listRowBackground(Color.itemBg)
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
                .listRowBackground(Color.bgColor)
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

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(url: item.avatar, size: 40)
                .to { UserDetailPage(userId: item.username)}
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .foregroundColor(Color.primaryText)
                    .greedyWidth(.leading)
                    .background(Color.itemBg)
                    .to { FeedDetailPage(id: item.feedId) }
                RichText {
                    item.content
                        .rich(baseStyle: quoteFont)
                }
                .debug()
                .padding(10)
                .background {
                    HStack(spacing: 0) {
                        Color.tintColor.opacity(0.8)
                            .frame(width: 3)
                        Color.lightGray
                    }
                    .clipCorner(1.5, corners: [.topLeft, .bottomLeft])
                }
                .visibility(item.content.isEmpty ? .gone : .visible)
                if !item.time.isEmpty {
                    Text(item.time)
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }
        }
        .padding(12)
        .background(Color.itemBg)
        .divider()
    }

}

struct MessagePage_Previews: PreviewProvider {
    static var selected = TabId.message
    static var previews: some View {
        MessagePage(selecedTab: .message)
            .environmentObject(Store.shared)
    }
}
