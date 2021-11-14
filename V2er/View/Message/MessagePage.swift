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
    
    var body: some View {
        contentView
            .background(Color.bgColor)
            .hide(!isSelected)
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(spacing: 0) {
            ForEach(state.model.items) { item in
                MessageItemView(item: item)
            }
        }
        .updatable(state.updatableState) {
            await run(action: MessageActions.FetchStart())
        } loadMore: {
            await run(action: MessageActions.LoadMoreStart())
        }
    }
}

struct MessageItemView: View {
    let item: MessageInfo.Item
    let quoteFont = Style.font(UIFont.prfered(.subheadline))
        .foregroundColor(Color.bodyText.uiColor)

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(url: item.avatar, size: 40)
                .to { UserDetailPage(userId: item.username)}
            VStack(alignment: .leading) {
                Text(item.title)
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
