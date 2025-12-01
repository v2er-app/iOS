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
                    RecentItemView(data: item)
                        .background(Color.itemBg)
                        .to {
                            FeedDetailPage(id: item.id)
                        }
                }
            }
        }
        .navBar("最近浏览")
    }
}

struct RecentItemView<Data: FeedItemProtocol>: View {
    let data: Data

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
                        .foregroundColor(Color.tintColor)
                }
                Spacer()
                NavigationLink(destination: TagDetailPage(tagId: data.nodeId.safe)) {
                    Text(data.nodeName.safe)
                        .font(.footnote)
                        .foregroundColor(Color.dynamic(light: .hex(0x666666), dark: .hex(0xCCCCCC)))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.dynamic(light: Color.hex(0xF5F5F5), dark: Color.hex(0x2C2C2E)))
                }
                .buttonStyle(.plain)
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
