//
//  MessagePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import SwiftSoup

struct MessagePage: BaseHomePageView {
    @EnvironmentObject private var store: Store
    var bindingState: Binding<MessageState> {
        $store.appState.messageState
    }
    var selecedTab: TabId

    var isSelected: Bool {
        let selected = selecedTab == .message
        if selected && !state.hasLoadedOnce {
            dispatch(action: MessageActions.FetchStart(autoLoad: true))
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
            ForEach(state.model.items) { item in
                NavigationLink(destination: FeedDetailPage()) {
                    MessageItemView(item: item)
                    Divider()
                }
            }
        }
        .background(Color.pageLight)
        .updatable(state.updatableState) {
            await run(action: MessageActions.FetchStart())
        } loadMore: {
            await run(action: MessageActions.LoadMoreStart())
        }
    }
}

struct MessageItemView: View {
    let item: MessageInfo.Item

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(url: item.avatar, size: 40)
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.subheadline)
                    .greedyWidth(.leading)
                Text(item.content)
                    .greedyWidth(.leading)
                    .font(.footnote)
                    .lineLimit(3)
                    .padding(10)
                    .background {
                        HStack(spacing: 0) {
                            Color.tintColor.opacity(0.8)
                                .frame(width: 3)
                            Color.lightGray
                        }
                    }
                    .visibility(item.content.isEmpty ? .gone : .visible)
            }
        }
        .padding(12)
        .divider()
    }

}

struct MessagePage_Previews: PreviewProvider {
    static var selected = TabId.message
    static var previews: some View {
        MainPage()
            .environmentObject(Store.shared)
    }
}
