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
            dispatch(action: ExploreActions.FetchData.Start(autoLoad: true))
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
        let todayHotList = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("今日热议")
            ForEach(state.exploreInfo.dailyHotInfo) { item in
                HStack(spacing: 12) {
                    NavigationLink(destination: UserDetailPage(userId: item.member)) {
                        AvatarView(url: item.avatar, size: 30)
                    }
                    NavigationLink(destination: FeedDetailPage(initData: FeedInfo.Item.create(from: item.id))) {
                        Text(item.title)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(.bodyText)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 8)
                Divider().opacity(0.6)
            }
        }
        
        let hotNodesItem = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("最热节点")
            FlowStack(data: state.exploreInfo.hottestNodeInfo) { node in
                NodeView(node: node)
            }
        }
        
        let newlyAddedItem = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("新增节点")
            FlowStack(data: state.exploreInfo.recentNodeInfo) { node in
                NodeView(node: node)
            }
        }
        
        let navNodesItem =
        VStack(spacing: 0) {
            SectionTitleView("节点导航")
            ForEach(state.exploreInfo.nodeNavInfo) {
                NodeNavItemView(data: $0)
            }
        }
        
        VStack(spacing: 0) {
            todayHotList
            hotNodesItem
            newlyAddedItem
            navNodesItem
        }
        .padding(.top, 4)
        .padding(.horizontal, 10)
        .background(Color.pageLight)
        .hide(state.refreshing)
        .updatable(autoRefresh: state.showProgressView, scrollTop(tab: .explore)) {
            await run(action: ExploreActions.FetchData.Start())
        }
        .hide(!isSelected)
    }

}


struct NodeNavItemView: View {

    let data: ExploreInfo.NodeNavItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitleView(data.category, style: .small)
            FlowStack(data: data.nodes) { node in
                NodeView(node: node)
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
