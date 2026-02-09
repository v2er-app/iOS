//
//  SpecailCarePage.swift
//  SpecailCarePage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct MyFollowPage: StateView {
    @ObservedObject private var store = Store.shared
    @State private var isLoadingMore = false

    var bindingState: Binding<MyFollowState> {
        return $store.appState.myFollowState
    }

    var body: some View {
        contentView
            .onAppear {
                dispatch(MyFollowActions.FetchStart(autoLoad: !state.updatableState.hasLoadedOnce))
            }
            .navigationTitle("我的关注")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }

    @ViewBuilder
    private var contentView: some View {
        List {
            ForEach(state.model?.items ?? []) { item in
                FeedItemView(data: item)
                    .background {
                        NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                            .opacity(0)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
            }

            // Load More Indicator
            if state.updatableState.hasMoreData && !(state.model?.items ?? []).isEmpty {
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
                .listRowBackground(Color(.systemBackground))
                .onAppear {
                    guard !isLoadingMore else { return }
                    isLoadingMore = true
                    Task {
                        await run(action: MyFollowActions.LoadMoreStart())
                        await MainActor.run {
                            isLoadingMore = false
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: MyFollowActions.FetchStart(autoLoad: false))
        }
        .overlay {
            if state.updatableState.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

struct SpecailCarePage_Previews: PreviewProvider {
    static var previews: some View {
        MyFollowPage()
    }
}
