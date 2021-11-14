//
//  MyTopicPage.swift
//  MyTopicPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct UserFeedPage: StateView, InstanceIdentifiable {
    @EnvironmentObject private var store: Store
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.isPresented) private var isPresented
    let userId: String
    var instanceId: String { userId }

    var bindingState: Binding<UserFeedState> {
        if store.appState.userFeedStates[instanceId] == nil {
            store.appState.userFeedStates[instanceId] = UserFeedState()
        }
        return $store.appState.userFeedStates[instanceId]
    }

    var body: some View {
        contentView
            .updatable(state.updatableState) {
                await run(action: UserFeedActions.FetchStart(id: instanceId, userId: userId, autoLoad: false))
            } loadMore: {
                await run(action: UserFeedActions.LoadMoreStart(id: instanceId, userId: userId))
            }
            .onAppear {
                dispatch(UserFeedActions.FetchStart(id: instanceId, userId: userId, autoLoad: !state.hasLoadedOnce))
            }
            .navBar("\(userId)的全部主题")
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(spacing: 0) {
            ForEach(state.model.items) { item in
                NavigationLink {
                    FeedDetailPage(id: item.id)
                } label: {
                    ItemView(data: item)
                }
            }
        }
    }

    struct ItemView: View {
        var data: UserFeedInfo.Item

        var body: some View {
            VStack(spacing: 4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(data.userName)
                            .lineLimit(1)
                        Text(data.replyUpdate)
                            .lineLimit(1)
                            .font(.footnote)
                            .greedyWidth(.leading)
                            .foregroundColor(Color.tintColor)
                    }
                    Spacer()
                    NavigationLink(destination: TagDetailPage()) {
                        Text(data.tag)
                            .font(.footnote)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.lightGray)
                    }
                }
                Text(data.title)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                Text("评论\(data.replyNum)")
                    .lineLimit(1)
                    .font(.footnote)
                    .greedyWidth(.trailing)
            }
            .padding(12)
            .divider()
            .background(Color.itemBg)
        }
    }

}

struct MyTopicPage_Previews: PreviewProvider {
    static var previews: some View {
        UserFeedPage(userId: .empty)
            .environmentObject(Store.shared)
    }
}
