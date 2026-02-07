//
//  ExplorePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct ExplorePage: BaseHomePageView {
    @EnvironmentObject private var store: Store
    @State private var isLoadingMore = false
    var bindingState: Binding<ExploreState> {
        $store.appState.exploreState
    }
    var selecedTab: TabId

    private var searchState: SearchState {
        store.appState.searchState
    }
    private var searchKeyword: Binding<String> {
        $store.appState.searchState.keyword
    }
    private var searchSortWay: Binding<String> {
        $store.appState.searchState.sortWay
    }
    private var isSearching: Bool {
        !searchState.keyword.isEmpty
    }

    var isSelected: Bool {
        let selected = selecedTab == .explore
        if selected && !state.hasLoadedOnce {
            dispatch(ExploreActions.FetchData.Start(autoLoad: true))
        }
        return selected
    }

    var scrollToTop: Bool {
        if store.appState.globalState.scrollTopTab == .explore {
            store.appState.globalState.scrollTopTab = .none
            return true
        }
        return false
    }

    var body: some View {
        browseContent
            .overlay {
                if isSearching {
                    searchResultsView
                }
            }
            .searchable(text: searchKeyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索主题")
            .background(Color(.systemGroupedBackground))
            .onSubmit(of: .search) {
                dispatch(SearchActions.Start())
            }
            .onChange(of: searchState.sortWay) { _ in
                dispatch(SearchActions.Start())
            }
            .onAppear {
                if !state.hasLoadedOnce {
                    dispatch(ExploreActions.FetchData.Start(autoLoad: true))
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Browse Content (idle state)

    @ViewBuilder
    private var browseContent: some View {
        List {
            // Today Hot Section
            if !state.exploreInfo.dailyHotInfo.isEmpty {
                Section {
                    ForEach(Array(state.exploreInfo.dailyHotInfo.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: Spacing.md) {
                            Text("\(index + 1)")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(index < 3 ? .accentColor : .tertiaryText)
                                .frame(width: 20)
                            AvatarView(url: item.avatar, size: 30)
                            Text(item.title)
                                .foregroundColor(Color.primaryText)
                                .lineLimit(2)
                                .greedyWidth(.leading)
                        }
                        .padding(.vertical, Spacing.md)
                        .background {
                            NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                .opacity(0)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: Spacing.sm, bottom: 0, trailing: Spacing.sm))
                        .listRowBackground(Color(.systemGroupedBackground))
                    }
                } header: {
                    SectionTitleView("今日热议")
                        .listRowInsets(EdgeInsets(top: 0, leading: Spacing.lg, bottom: 0, trailing: Spacing.sm))
                        .listRowBackground(Color(.systemGroupedBackground))
                }
                .listRowSeparator(.hidden)
            }

            // Hot Nodes Section
            if !state.exploreInfo.hottestNodeInfo.isEmpty {
                Section {
                    FlowStack(data: state.exploreInfo.hottestNodeInfo) { node in
                        NodeView(id: node.id, name: node.name)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: Spacing.sm, bottom: 0, trailing: Spacing.sm))
                    .listRowBackground(Color(.systemGroupedBackground))
                } header: {
                    SectionTitleView("最热节点")
                        .listRowBackground(Color(.systemGroupedBackground))
                }
                .listRowSeparator(.hidden)
            }

            // New Nodes Section
            if !state.exploreInfo.recentNodeInfo.isEmpty {
                Section {
                    FlowStack(data: state.exploreInfo.recentNodeInfo) { node in
                        NodeView(id: node.id, name: node.name)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: Spacing.sm, bottom: 0, trailing: Spacing.sm))
                    .listRowBackground(Color(.systemGroupedBackground))
                } header: {
                    SectionTitleView("新增节点")
                        .listRowBackground(Color(.systemGroupedBackground))
                }
                .listRowSeparator(.hidden)
            }

            // Node Navigation Section
            if !state.exploreInfo.nodeNavInfo.isEmpty {
                Section {
                    ForEach(state.exploreInfo.nodeNavInfo) { navItem in
                        NodeNavItemView(data: navItem)
                            .listRowInsets(EdgeInsets(top: 0, leading: Spacing.sm, bottom: 0, trailing: Spacing.sm))
                            .listRowBackground(Color(.systemGroupedBackground))
                    }
                } header: {
                    SectionTitleView("节点导航")
                        .listRowBackground(Color(.systemGroupedBackground))
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: ExploreActions.FetchData.Start())
        }
        .overlay {
            if state.showProgressView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }

    // MARK: - Search Results (searching state)

    @ViewBuilder
    private var searchResultsView: some View {
        List {
            sortPickerView
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))

            ForEach(searchState.model?.hits ?? []) { item in
                SearchResultItemView(hint: item)
                    .cardScrollTransition()
                    .background {
                        NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                            .opacity(0)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemGroupedBackground))
            }

            // Load More Indicator
            if searchState.updatable.hasMoreData && !(searchState.model?.hits ?? []).isEmpty {
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
        .background(Color(.systemGroupedBackground))
        .overlay {
            if searchState.updatable.showLoadingView {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }

    @ViewBuilder
    private var sortPickerView: some View {
        Picker("Sort", selection: searchSortWay) {
            Text("相关")
                .tag("sumup")
            Text("最新")
                .tag("created")
        }
        .font(.headline)
        .pickerStyle(.segmented)
    }
}


// MARK: - Search Result Item

private struct SearchResultItemView: View {
    let hint: SearchState.Model.Hit
    var data: SearchState.Model.Hit.Source {
        hint.source
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(data.title)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
            Text(data.content)
                .foregroundColor(.secondaryText)
                .lineLimit(3)
                .padding(.vertical, Spacing.xxs)
            Text("\(data.creator) 于 \(data.created) 发表, \(data.replyNum) 回复")
                .font(AppFont.metadata)
                .foregroundColor(.tertiaryText)
        }
        .greedyWidth()
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.sm)
        .padding(.bottom, Spacing.sm)
    }
}


struct NodeNavItemView: View {

    let data: ExploreInfo.NodeNavItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitleView(data.category, style: .small)
            FlowStack(data: data.nodes) { node in
                NodeView(id: node.id, name: node.name)
            }
        }
    }

}

struct ExplorePage_Previews: PreviewProvider {
    static var selected = TabId.explore

    static var previews: some View {
        ExplorePage(selecedTab: selected)
    }
}
