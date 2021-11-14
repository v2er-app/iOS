//
//  TabBar.swift
//  V2er
//
//  Created by Seth on 2020/5/24.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct TabBar: View {
    @EnvironmentObject private var store: Store
    var selectedTab : TabId {
        store.appState.globalState.selectedTab
    }
    
    var tabs = [TabItem(id: TabId.feed, text: "最新", icon: "feed_tab"),
                TabItem(id: TabId.explore, text: "发现", icon: "explore_tab"),
                TabItem(id: TabId.message, text: "通知", icon: "message_tab"),
                TabItem(id: TabId.me, text: "我", icon: "me_tab")]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().frame(height: 0.1)
            HStack(spacing: 0) {
                ForEach (self.tabs, id: \.self) { tab in
                    let isSelected: Bool = self.selectedTab == tab.id
                    Button {
                        dispatch(TabbarClickAction(selectedTab: tab.id))
                    } label: {
                        VStack (spacing: 0) {
                            Color(self.selectedTab == tab.id ? "indictor" : "clear")
                                .frame(height: 3)
                                .cornerRadius(0)
                            Image(tab.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                                .padding(.top, 8)
                                .padding(.bottom, 2.5)
                            Text(tab.text)
                                .font(.caption)
                                .fontWeight(isSelected ? .semibold : .regular)
                                .padding(.bottom, 8)
                        }
                        .foregroundColor(Color.tintColor)
                        .background(self.bg(isSelected: isSelected))
                        .padding(.horizontal, 16)
                        .background(Color.almostClear)
                    }
//                    .debug()
                }
            }
        }
        .padding(.bottom, topSafeAreaInset().bottom)
        .background(VEBlur())
    }
    
    
    func bg(isSelected : Bool) -> some View {
        return LinearGradient(
            gradient:Gradient(colors: isSelected ?
                              [Color.hex(0xBFBFBF, alpha: 0.2), Color.hex(0xBFBFBF, alpha: 0.1), Color.hex(0xBFBFBF, alpha: 0.05), Color.hex(0xBFBFBF, alpha: 0.01)] : [])
            , startPoint: .top, endPoint: .bottom)
            .padding(.top, 3)
    }
    
}



enum TabId: String {
    case none
    case feed, explore, message, me
}

class TabItem : Hashable {
    let id : TabId
    var text : String
    var icon : String
    
    init(id: TabId, text : String, icon : String) {
        self.id = id
        self.text = text
        self.icon = icon
    }
    
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

struct TabBar_Previews : PreviewProvider {
//    @State static var selected = TabId.feed
    
    static var previews: some View {
        VStack {
            Spacer()
            TabBar()
                .background(VEBlur())
        }
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(Store.shared)
    }
    
}

