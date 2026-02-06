//
//  SearchPage.swift
//  SearchPage
//
//  Created by Seth on 2021/7/18.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct SearchPage: StateView {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var store: Store
    @State private var isLoadingMore = false
    var bindingState: Binding<SearchState> {
        return $store.appState.searchState
    }

    var body: some View {
        List {
            // Sort picker at top
            sortPickerView
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.bgColor)

            ForEach(state.model?.hits ?? []) { item in
                NavigationLink(destination: FeedDetailPage(id: item.id)) {
                    SearchResultItemView(hint: item)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.bgColor)
            }

            // Load More Indicator
            if state.updatable.hasMoreData && !(state.model?.hits ?? []).isEmpty {
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
                        await run(action: SearchActions.LoadMoreStart())
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
        .background(Color.bgColor)
        .navigationTitle("搜索")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: bindingState.keyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "Powered by sov2ex.com")
        .onSubmit(of: .search) {
            dispatch(SearchActions.Start())
        }
        .onChange(of: state.sortWay) { sort in
            dispatch(SearchActions.Start())
        }
        .overlay {
            if state.updatable.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }

    @ViewBuilder
    private var sortPickerView: some View {
        Picker("Sort", selection: bindingState.sortWay) {
            Text("相关")
                .tag("sumup")
            Text("最新")
                .tag("created")
        }
        .font(.headline)
        .pickerStyle(.segmented)
    }
}

fileprivate struct SearchResultItemView: View {
    let hint: SearchState.Model.Hit
    var data: SearchState.Model.Hit.Source {
        hint.source
    }
    
    var body: some View {
        let padding: CGFloat = 16
        VStack(alignment: .leading) {
            Text(data.title)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
            Text(data.content)
                .foregroundColor(.secondaryText)
                .lineLimit(5)
                .padding(.vertical, 5)
            Text("\(data.creator) 于 \(data.created) 发表, \(data.replyNum) 回复")
                .font(.footnote)
                .foregroundColor(Color.tintColor.opacity(0.8))
        }
        .greedyWidth()
        .padding(padding)
        .background(Color.itemBg)
        .padding(.bottom, 8)
    }
}


struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
            .environmentObject(Store.shared)
    }
}
