//
//  UserDetailPage.swift
//  UserDetailPage
//
//  Created by Seth on 2021/7/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher
import Atributika

private struct UserDetailScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct UserDetailPage: StateView {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.isPresented) private var isPresented
    @EnvironmentObject private var store: Store
    @State private var scrollY: CGFloat = 0.0
    private let heightOfNodeImage = 60.0
    @State private var bannerViewHeight: CGFloat = 0
    @State private var currentTab: TabButton.ID = .topic
    @Namespace var animation
    // FIXME: couldn't be null
    var userId: String = .empty

    var bindingState: Binding<UserDetailState> {
        if store.appState.userDetailStates[userId] == nil {
            store.appState.userDetailStates[userId] = UserDetailState()
        }
        return $store.appState.userDetailStates[userId]
    }

    var model: UserDetailInfo {
        state.model
    }

    private var shouldHideNavbar: Bool {
        scrollY > -heightOfNodeImage * 1.0
    }

    private var statusBarStyle: UIStatusBarStyle {
        shouldHideNavbar ? .lightContent : .darkContent
    }

    var foreGroundColor: SwiftUI.Color {
        return shouldHideNavbar ? Color.primaryText.opacity(0.9) : .tintColor
    }

    var body: some View {
        contentView
            .statusBarStyle(statusBarStyle, original: .darkContent)
    }

    @ViewBuilder
    private var contentView: some View {
        ZStack(alignment: .top) {
            navBar
                .zIndex(1)
            List {
                // Banner Section
                topBannerView
                    .readSize {
                        bannerViewHeight = $0.height
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: UserDetailScrollOffsetKey.self,
                                value: geometry.frame(in: .named("userDetailScroll")).minY
                            )
                        }
                    )

                // Tabs Section
                tabsTitleView
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.itemBackground)

                // Bottom Detail Section - Topics
                if currentTab == .topic {
                    ForEach(model.topicInfo.items) { item in
                        NavigationLink(destination: FeedDetailPage(initData: FeedInfo.Item(id: item.id))) {
                            TopicItemView(data: item)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.itemBg)
                    }

                    // More topics link
                    if model.topicInfo.items.count > 0 {
                        Text("\(userId)创建的更多主题")
                            .font(.subheadline)
                            .padding()
                            .padding(.bottom, 12)
                            .to { UserFeedPage(userId: userId) }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.itemBg)
                    } else {
                        Text("根据 \(userId) 的设置，主题列表被隐藏")
                            .greedyFrame()
                            .font(.subheadline)
                            .padding()
                            .padding(.bottom, 180)
                            .hide(state.refreshing)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.itemBg)
                    }
                }

                // Bottom Detail Section - Replies
                if currentTab == .reply {
                    ForEach(model.replyInfo.items) { item in
                        NavigationLink(destination: FeedDetailPage(initData: FeedInfo.Item(id: item.id))) {
                            ReplyItemView(data: item)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.itemBg)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 1)
            .refreshable {
                await run(action: UserDetailActions.FetchData.Start(id: self.userId))
            }
            .coordinateSpace(name: "userDetailScroll")
            .onPreferenceChange(UserDetailScrollOffsetKey.self) { offset in
                self.scrollY = offset
            }
            .background {
                VStack(spacing: 0) {
                    let height = bannerViewHeight * 1.2 + max(scrollY, 0)
                    KFImage
                        .url(URL(string: model.avatar))
                        .fade(duration: 0.25)
                        .resizable()
                        .blur(radius: 80, opaque: true)
                        .overlay(Color.dynamic(light: .black, dark: .white).opacity(withAnimation {shouldHideNavbar ? 0.3 : 0.1}))
                        .frame(maxWidth: .infinity, maxHeight: height)
                    Spacer().background(.clear)
                }
                .debug()
            }
            .overlay {
                if state.showProgressView {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
        .onAppear {
            log("onAppear----")
            dispatch(UserDetailActions.FetchData.Start(id: userId, autoLoad: true))
        }
        .onDisappear {
            log("onDisappear----")
            if !isPresented {
                log("onPageClosed----->")
                //                dispatch(InstanceDestoryAction(target: .userdetail, id: instanceId))
            }
        }
    }
    
    @ViewBuilder
    private var navBar: some View  {
        NavbarHostView(paddingH: 0, hideDivider: shouldHideNavbar) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                }
                .forceClickable()
                
                Group {
                    AvatarView(url: model.avatar, size: 36)
                        .overlay {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                                .offset(x: 9, y: 36/2 - 2)
                        }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(model.userName)
                            .font(.headline)
                        Text(model.desc)
                            .font(.subheadline)
                        //                        Circle().fill(.green).frame(width: 8, height: 8)
                    }
                    .lineLimit(1)
                }
                .opacity(shouldHideNavbar ? 0.0 : 1.0)
                
                Spacer()
                
                Button {
                    dispatch(UserDetailActions.Follow(id: userId))
                } label: {
                    Image(systemName: state.model.hasFollowed ? "heart.fill" : "heart")
                        .padding(8)
                        .font(.title3.weight(.regular))
                        .hide(isSelf())
                }
                .opacity(shouldHideNavbar ? 0.0 : 1.0)
                .forceClickable()
                
                Button {
                    dispatch(UserDetailActions.BlockUser(id: userId))
                } label: {
                    Image(systemName: state.model.hasBlocked ? "eye.slash.fill" : "eye.slash")
                        .padding(8)
                        .font(.body.weight(.regular))
                        .hide(isSelf())
                }
                .forceClickable()
            }
            .padding(.vertical, 5)
        }
        .foregroundColor(foreGroundColor)
        .visualBlur(alpha: shouldHideNavbar ? 0.0 : 1.0)
    }

    private func isSelf() -> Bool {
        AccountState.isSelf(userName: userId)
    }
    
    @ViewBuilder
    private var topBannerView: some View {
        VStack (spacing: 14) {
            Color.clear.frame(height: topSafeAreaInset().top)
            AvatarView(url: model.avatar, size: heightOfNodeImage)
            HStack(alignment: .center,spacing: 4) {
                Circle()
                    .fill(state.model.isOnline ? .green : Color.secondaryText)
                    .frame(width: 8, height: 8)
                Text(model.userName)
                    .font(.headline.weight(.semibold))
            }
            Button {
                dispatch(UserDetailActions.Follow(id: userId))
            } label: {
                Text(state.model.hasFollowed ? "已关注" : "关注")
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 2)
                    .cornerBorder(radius: 99, borderWidth: 1,
                                  color: foreGroundColor)
            }
            .hide(isSelf())
            Text(model.desc)
                .font(.callout)
        }
        .foregroundColor(foreGroundColor)
        .padding(.vertical, 8)
    }
    
    private var tabsTitleView: some View {
        HStack(spacing: 0) {
            TabButton(title: "主题", id: .topic, selectedID: $currentTab, animation: self.animation)
            TabButton(title: "回复", id: .reply, selectedID: $currentTab, animation: self.animation)
        }
        .background(Color.lightGray, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.itemBackground)
        .clipCorner(12, corners: [.topLeft, .topRight])
    }
    


    struct ReplyItemView: View {
        var data: UserDetailInfo.ReplyInfo.Item
        let quoteFont = Style.font(UIFont.prfered(.footnote))
            .foregroundColor(Color.primaryText.uiColor)

        var body: some View {
            VStack(spacing: 0) {
                Text(data.title)
                    .font(.footnote)
                    .foregroundColor(.primaryText)
                    .greedyWidth(.leading)
                RichText {
                    data.content
                        .rich(baseStyle: quoteFont)
                }
                .font(.footnote)
                .padding(12)
                .background {
                    HStack(spacing: 0) {
                        Color.tintColor.opacity(0.8)
                            .frame(width: 3)
                        Color.lightGray
                    }
                    .clipCorner(1.5, corners: [.topLeft, .bottomLeft])
                }
                .padding(.vertical, 6)
                Text(data.time)
                    .font(.footnote)
                    .foregroundColor(.secondaryText)
                    .greedyWidth(.trailing)
            }
            .padding(12)
            .divider()
        }
    }


    struct TopicItemView: View {
        var data: UserDetailInfo.TopicInfo.Item

        var body: some View {
            VStack(spacing: 0) {
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(data.userName)
                                .lineLimit(1)
                            Text(data.time)
                                .lineLimit(1)
                                .font(.footnote)
                        }
                        Spacer()
                        Text(data.tag)
                            .font(.footnote)
                            .foregroundColor(Color.primaryText)
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.lightGray)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .to { TagDetailPage() }
                    }
                    Text(data.title )
                        .greedyWidth(.leading)
                        .lineLimit(2)
                }
                .padding(12)
                Divider()
            }
            .background(Color.almostClear)
        }
    }

    struct TabButton: View {
        public enum ID: String {
            case topic, reply
        }

        var title: String
        var id: ID
        @Binding var selectedID: ID
        var animation: Namespace.ID


        var isSelected: Bool {
            return id == selectedID
        }

        var body: some View {
            Button {
                withAnimation(.spring()) {
                    selectedID = id
                }
            } label: {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? Color.itemBackground.opacity(0.9) : .tintColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        VStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primaryText)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }
                        }
                    }
                    .forceClickable()
            }
        }

    }

}

//struct UserDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailPage()
//    }
//}
