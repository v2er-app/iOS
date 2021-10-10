//
//  MePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MePage: BaseHomePageView {
    @EnvironmentObject private var store: Store
    var bindingState: Binding<MeState> {
        $store.appState.meState
    }
    var selecedTab: TabId
    var isSelected: Bool {
        let selected = selecedTab == .me
        return selected
    }
    
    var body: some View {
        ScrollView {
            topBannerView
            sectionViews
        }
        .background(Color.bgColor)
        .overlay {
            if !AccountState.hasSignIn() {
                VStack {
                    Text("登录查看更多")
                        .foregroundColor(.white)
                        .font(.title2)
                    Button {
                        dispatch(action: MeActions.ShowLoginPageAction())
                    } label: {
                        Text("登录")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.horizontal, 50)
                            .background(Color.black)
                            .cornerRadius(15)
                    }
                }
                .greedyFrame()
                .background(Color.dim)
                .sheet(isPresented: bindingState.showLoginView) {
                    LoginPage()
                }
            }
        }
        .opacity(selecedTab == .me ? 1.0 : 0.0)
    }
    
    @ViewBuilder
    private var topBannerView: some View {
        HStack(spacing: 10) {
            AvatarView(url: AccountState.avatarUrl, size: 60)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AccountState.userName)
                        .font(.headline)
                    Text("")
                        .font(.footnote)
                }
                Spacer()
            }
            HStack {
                Text("个人主页")
                    .font(.subheadline)
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
                SectionItemView("发贴", icon: "pencil", showDivider: false)
                    .padding(.bottom, 8)
            }
            NavigationLink {
                UserFeedPage(userId: AccountState.userName)
            } label: {
                SectionItemView("主题", icon: "paperplane")
            }
            
            NavigationLink {
                MyFavoritePage()
            } label: {
                SectionItemView("收藏", icon: "bookmark")
            }
            NavigationLink {
                MyFollowPage()
            } label: {
                SectionItemView("关注", icon: "heart")
            }
            NavigationLink {
                MyRecentPage()
            } label: {
                SectionItemView("最近浏览", icon: "clock", showDivider: false)
            }
            
            NavigationLink {
                SettingsPage()
            } label: {
                SectionItemView("设置", icon: "gearshape", showDivider: false)
                    .padding(.top, 8)
            }
        }
    }
    
}

struct SectionItemView: View {
    let title: String
    var showDivider: Bool = true
    let icon: String
    
    public init(_ title: String, icon: String, showDivider: Bool = true) {
        self.title = title
        self.icon = icon
        self.showDivider = showDivider
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .padding(.leading, 16)
                .padding(.trailing, 5)
                .foregroundColor(.tintColor)
            
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
                        .opacity(showDivider ? 0.5 : 0.0)
                }
            }
        }
        .background(.white)
    }
}

struct AccountPage_Previews: PreviewProvider {
    static var selected = TabId.me
    
    static var previews: some View {
        MePage(selecedTab: selected)
            .environmentObject(Store.shared)
    }
}
