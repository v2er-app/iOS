//
//  MePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MePage: View {
    @Binding var selecedTab: TabId
    
    var body: some View {
        ScrollView {
            NavigationLink {
                UserDetailPage()
            } label: {
                topBannerView
            }
            sectionViews
        }
        .background(Color.bgColor)
        .opacity(selecedTab == .me ? 1.0 : 0.0)
    }
    
    @ViewBuilder
    private var topBannerView: some View {
        HStack(spacing: 10) {
            AvatarView(size: 50)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("ghui")
                        .font(.headline)
                    Text("已签到666天")
                        .font(.footnote)
                }
                Spacer()
            }
            HStack {
                Text("个人主页")
                    .font(.callout)
                    .foregroundColor(Color.bodyText)
                Image(systemName: "chevron.right")
                    .font(.body.weight(.regular))
                    .foregroundColor(Color.gray)
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(.white)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var sectionViews: some View {
        VStack(spacing: 0) {
            NavigationLink {
                CreateTopicPage()
            } label: {
                SectionItemView(title: "发贴", showDivider: false)
                    .padding(.bottom, 8)
            }
            SectionItemView(title: "主题")
            SectionItemView(title: "收藏")
            SectionItemView(title: "关注")
            SectionItemView(title: "最近浏览", showDivider: false)
            NavigationLink {
                CreateTopicPage()
            } label: {
                SectionItemView(title: "设置", showDivider: false)
                    .padding(.top, 8)
            }
        }
    }
    
}

struct SectionItemView: View {
    let title: String
    var showDivider: Bool = true
    
    public init(title: String, showDivider: Bool = true) {
        self.title = title
        self.showDivider = showDivider
    }
    
    var body: some View {
        HStack {
            Image(systemName: "pencil")
                .padding(.leading, 16)
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.regular))
                    .foregroundColor(.gray)
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 17)
            .background {
                VStack {
                    Spacer()
                    Divider()
                        .foregroundColor(.lightGray)
                        .opacity(showDivider ? 1.0 : 0.0)
                }
            }
        }
        .background(.white)
    }
}

struct AccountPage_Previews: PreviewProvider {
    @State static var selected = TabId.me
    
    static var previews: some View {
        MePage(selecedTab: $selected)
    }
}
