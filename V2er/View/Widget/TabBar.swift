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
    var unReadMsg: Int = 0
    var tabs: [TabItem]
    
    init(_ unReadMsg: Int = 0) {
        self.tabs = [TabItem(id: TabId.feed, text: "最新", icon: "feed_tab"),
                     TabItem(id: TabId.explore, text: "发现", icon: "explore_tab"),
                     TabItem(id: TabId.message, text: "通知", icon: "message_tab", badge: unReadMsg),
                     TabItem(id: TabId.me, text: "我", icon: "me_tab")]
    }


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
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                                .padding(.bottom, 2.5)
                                .padding(.top, 8)
                                .padding(.horizontal, 8)
                                .overlay {
                                    // badge
                                    Group {
                                        if tab.badge > 0 {
                                            badgeView(num: tab.badge)
                                        }
                                    }
                                }
                            Text(tab.text)
                                .font(.caption)
                                .fontWeight(isSelected ? .semibold : .regular)
                                .padding(.bottom, 8)
                        }
                        .foregroundColor(isSelected ? Color.tintColor : Color.tintColor.opacity(0.6))
                        .background(self.bg(isSelected: isSelected))
                        .padding(.horizontal, 16)
                        .background(Color.almostClear)

                    }
                }
            }
        }
        .padding(.bottom, topSafeAreaInset().bottom)
        .background(VEBlur())
    }

    private func badgeView(num: Int) -> some View {
        HStack(alignment: .top) {
            Spacer()
            VStack {
                Text(num.string)
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(4)
                    .background {
                        Circle()
                            .fill(Color.red)
                    }
                Spacer()
            }
        }
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
    var badge: Int = 0
    
    init(id: TabId, text : String, icon : String, badge: Int = 0) {
        self.id = id
        self.text = text
        self.icon = icon
        self.badge = badge
    }
    
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.badge == rhs.badge
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

