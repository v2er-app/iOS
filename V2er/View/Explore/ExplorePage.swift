//
//  ExplorePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct ExplorePage: View {
    @Binding var selecedTab: TabId
    
    var body: some View {
        let todayHotList = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("今日热议")
            ForEach(0...6, id: \.self) {_ in
                HStack {
                    Image("avar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .roundedEdge()
                    Text("有人用非等宽字体来写代码的吗？等宽字体显示代码有什么特殊的好处吗？")
                        .font(.callout)
                        .lineLimit(2)
                }
                .padding(.vertical, 12)
                Divider()
            }
        }
        
        let hotNodesItem = VStack(alignment: .leading, spacing: 0) {
            SectionTitleView("最热节点")
            FlowStack(data: ["问与答1", "问与答2",
                             "问与答333", "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答222"]) {
                Text($0)
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
            FlowStack(data: ["问与答1", "问与答2",
                             "问与答333", "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答222"]) {
                Text($0)
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
            FlowStack(data: ["问与答1", "问与答2",
                             "问与答333", "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答4", "问与答55", "问与答6", "问与答77", "问与答888", "9", "10", "11",
                             "问与答222"]) {
                Text($0)
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
        .updatable {
            print("onRefresh...")
        }
        .opacity(selecedTab == .explore ? 1.0 : 0.0)
    }
    
}

//fileprivate struct 

struct ExplorePage_Previews: PreviewProvider {
    @State static var selected = TabId.explore
    
    static var previews: some View {
        ExplorePage(selecedTab: $selected)
    }
}
