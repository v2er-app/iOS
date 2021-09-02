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
                HStack {
                    NavigationLink(destination: UserDetailPage()) {
                        AvatarView(url: item.avatar, size: 24)
                    }
                    Text(item.title)
                        .font(.callout)
                        .lineLimit(2)
                }
                .padding(.vertical, 12)
                Divider()
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
        
        let navNodesItem = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("节点导航")
            FlowStack(data: state.exploreInfo.nodeNavInfo) {
                Text($0.category)
                    .font(.footnote)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.lightGray)
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
    
}

//fileprivate struct 

struct ExplorePage_Previews: PreviewProvider {
    static var selected = TabId.explore
    
    static var previews: some View {
        ExplorePage(selecedTab: selected)
    }
}
