//
//  ExplorePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct ExplorePage: StateView {
    @EnvironmentObject private var store: Store
    var state: ExploreState {
        store.appState.exploreState
    }
    var selecedTab: TabId
    
    var body: some View {
        let todayHotList = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("今日热议")
            ForEach(state.exploreInfo.dailyHotInfo) { item in
                HStack(spacing: 14) {
                    NavigationLink(destination: UserDetailPage()) {
                        AvatarView(url: item.avatar, size: 36)
                    }
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.bodyText)
                        .lineLimit(2)
                }
                .padding(.vertical, 12)
                Divider().opacity(0.6)
            }
        }
        
        let hotNodesItem = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("最热节点")
            FlowStack(data: state.exploreInfo.hottestNodeInfo) {
                Text($0.name)
                    .font(.footnote)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.lightGray)
            }
        }
        
        let newlyAddedItem = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("新增节点")
            FlowStack(data: state.exploreInfo.recentNodeInfo) {
                Text($0.name)
                    .font(.footnote)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.lightGray)
            }
        }
        
        let navNodesItem =
        VStack {
            SectionTitleView("节点导航")
            ForEach(state.exploreInfo.nodeNavInfo) {
                NodeNavItemView(data: $0)
            }
        }
        
        VStack {
            todayHotList
            hotNodesItem
            newlyAddedItem
            navNodesItem
        }
        .padding(.top, 4)
        .padding(.horizontal, 10)
        .onAppear {
            dispatch(action: ExploreActions.FetchData.Start(autoStart: true))
        }
        .updatable(autoRefresh: state.autoLoad) {
            await run(action: ExploreActions.FetchData.Start())
        }
        .opacity(selecedTab == .explore ? 1.0 : 0.0)
    }

    struct NodeNavItemView: View {

        let data: ExploreInfo.NodeNavItem

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                SectionTitleView(data.category, style: .small)
                FlowStack(data: data.nodes) {
                    Text($0.name)
                        .font(.footnote)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.lightGray)
                }
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
