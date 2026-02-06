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
    @State private var isLoadingMore = false
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
            .onAppear {
                dispatch(UserFeedActions.FetchStart(id: instanceId, userId: userId, autoLoad: !state.hasLoadedOnce))
            }
            .navigationTitle("\(userId)的全部主题")
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var contentView: some View {
        List {
            ForEach(state.model.items) { item in
                ZStack {
                    NavigationLink(destination: FeedDetailPage(id: item.id)) {
                        EmptyView()
                    }
                    .opacity(0)

                    ItemView(data: item)
                }
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
                        await run(action: UserFeedActions.LoadMoreStart(id: instanceId, userId: userId))
                        await MainActor.run {
                            isLoadingMore = false
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.bgColor)
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: UserFeedActions.FetchStart(id: instanceId, userId: userId, autoLoad: false))
        }
        .overlay {
            if state.updatableState.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
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
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        Text(data.replyUpdate)
                            .lineLimit(1)
                            .font(.footnote)
                            .greedyWidth(.leading)
                            .foregroundColor(Color.tintColor)
                    }
                    Spacer()
                    Text(data.tag)
                        .font(.footnote)
                        .foregroundColor(Color.dynamic(light: .hex(0x666666), dark: .hex(0xCCCCCC)))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.dynamic(light: Color.hex(0xF5F5F5), dark: Color.hex(0x2C2C2E)))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .to { TagDetailPage(tagId: data.tagId) }
                }
                Text(data.title)
                    .foregroundColor(.primaryText)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                Text("评论\(data.replyNum)")
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.secondaryText)
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
