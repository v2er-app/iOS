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
    var bindingState: Binding<ExploreState> {
        $store.appState.exploreState
    }
    var selecedTab: TabId

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
        List {
            // Today Hot Section
            if !state.exploreInfo.dailyHotInfo.isEmpty {
                Section {
                    ForEach(state.exploreInfo.dailyHotInfo) { item in
                        ZStack {
                            NavigationLink(destination: FeedDetailPage(initData: FeedInfo.Item(id: item.id))) {
                                EmptyView()
                            }
                            .opacity(0)

                            HStack(spacing: 12) {
                                AvatarView(url: item.avatar, size: 30)
                                Text(item.title)
                                    .foregroundColor(Color.primaryText)
                                    .lineLimit(2)
                                    .greedyWidth(.leading)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        .listRowBackground(Color.itemBg)
                    }
                } header: {
                    SectionTitleView("今日热议")
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.itemBg)
                }
                .listRowSeparator(.hidden)
            }

            // Hot Nodes Section
            if !state.exploreInfo.hottestNodeInfo.isEmpty {
                Section {
                    FlowStack(data: state.exploreInfo.hottestNodeInfo) { node in
                        NodeView(id: node.id, name: node.name)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .listRowBackground(Color.itemBg)
                } header: {
                    SectionTitleView("最热节点")
                        .listRowBackground(Color.itemBg)
                }
                .listRowSeparator(.hidden)
            }

            // New Nodes Section
            if !state.exploreInfo.recentNodeInfo.isEmpty {
                Section {
                    FlowStack(data: state.exploreInfo.recentNodeInfo) { node in
                        NodeView(id: node.id, name: node.name)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .listRowBackground(Color.itemBg)
                } header: {
                    SectionTitleView("新增节点")
                        .listRowBackground(Color.itemBg)
                }
                .listRowSeparator(.hidden)
            }

            // Node Navigation Section
            if !state.exploreInfo.nodeNavInfo.isEmpty {
                Section {
                    ForEach(state.exploreInfo.nodeNavInfo) { navItem in
                        NodeNavItemView(data: navItem)
                            .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            .listRowBackground(Color.itemBg)
                    }
                } header: {
                    SectionTitleView("节点导航")
                        .listRowBackground(Color.itemBg)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.itemBg)
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
        .onAppear {
            if !state.hasLoadedOnce {
                dispatch(ExploreActions.FetchData.Start(autoLoad: true))
            }
        }
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

//fileprivate struct

struct ExplorePage_Previews: PreviewProvider {
    static var selected = TabId.explore

    static var previews: some View {
        ExplorePage(selecedTab: selected)
    }
}
