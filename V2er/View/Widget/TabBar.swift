//
//  TabBar.swift
//  V2er
//
//  Created by Seth on 2020/5/24.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab : TabId
    
    var tabs = [TabItem(id: TabId.feed, text: "Feed", icon: "feed_tab"),
                TabItem(id: TabId.explore, text: "Explore", icon: "explore_tab"),
                TabItem(id: TabId.message, text: "Message", icon: "message_tab"),
                TabItem(id: TabId.me, text: "Me", icon: "me_tab")]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().frame(height: 0.1)
            HStack(spacing: 0) {
                ForEach (self.tabs, id: \.self) { tab in
                    Button(action: {
                        self.selectedTab = tab.id
                    }){
                        VStack (spacing: 0) {
                            Color(self.selectedTab == tab.id ? "indictor" : "clear")
                                .frame(height: 3)
                                .cornerRadius(0)
                            Image(tab.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                                .padding(.top, 8)
                                .padding(.bottom, 2.5)
                            Text(tab.text)
                                .font(.caption)
                                .padding(.bottom, 8)
                        }
                        .foregroundColor(Color(self.selectedTab == tab.id ? "selected" : "unselected"))
                        .background(self.bg(isSelected: self.selectedTab == tab.id))
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
    @State static var selected = TabId.feed
    
    static var previews: some View {
        VStack {
            Spacer()
            TabBar(selectedTab: $selected)
                .background(VEBlur())
        }.edgesIgnoringSafeArea(.bottom)
    }
    
}

