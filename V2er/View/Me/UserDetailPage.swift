//
//  UserDetailPage.swift
//  UserDetailPage
//
//  Created by Seth on 2021/7/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Atributika


struct UserDetailPage: StateView {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.isPresented) private var isPresented
    @EnvironmentObject private var store: Store
    @State private var scrollY: CGFloat = 0.0
    private let heightOfNodeImage = 60.0
    @State private var bannerViewHeight: CGFloat = 0
    @State private var dominantColor: SwiftUI.Color = .black
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
        guard bannerViewHeight > 0 else { return true }
        return scrollY < bannerViewHeight - heightOfNodeImage
    }

    private var statusBarStyle: UIStatusBarStyle {
        shouldHideNavbar ? .lightContent : .darkContent
    }

    var body: some View {
        contentView
            .statusBarStyle(statusBarStyle, original: .darkContent)
    }

    @ViewBuilder
    private var contentView: some View {
        ZStack(alignment: .top) {
            // Dominant color gradient background — edge-to-edge behind status bar
            VStack(spacing: 0) {
                let endColor = state.showProgressView ? dominantColor : Color(.systemGroupedBackground)
                LinearGradient(
                    stops: [
                        .init(color: dominantColor, location: 0),
                        .init(color: dominantColor, location: 0.7),
                        .init(color: endColor, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: bannerViewHeight * 1.5 + max(-scrollY, 0))
                .animation(.easeInOut(duration: 0.3), value: state.showProgressView)
                Color(.systemGroupedBackground)
            }
            .ignoresSafeArea(edges: .top)

            List {
                // Banner Section (includes rounded corner cap at bottom)
                topBannerView
                    .readSize {
                        bannerViewHeight = $0.height
                    }
                    .padding(.bottom, state.showProgressView ? 0 : 35)
                    .background(alignment: .bottom) {
                        if !state.showProgressView {
                            Color(.systemGroupedBackground)
                                .frame(height: 30)
                                .clipCorner(30, corners: [.topLeft, .topRight])
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                // Tabs Section
                tabsTitleView
                    .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemGroupedBackground))

                // Bottom Detail Section - Topics
                if currentTab == .topic {
                    ForEach(model.topicInfo.items) { item in
                        TopicItemView(data: item)
                            .cardScrollTransition()
                            .background {
                                NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                    .opacity(0)
                            }
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemGroupedBackground))
                    }

                    // More topics link
                    if model.topicInfo.items.count > 0 {
                        NavigationLink(value: AppRoute.userFeed(userId: userId)) {
                            Text("\(userId)创建的更多主题")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                                .padding(Spacing.lg)
                                .padding(.bottom, Spacing.md)
                        }
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemGroupedBackground))
                    } else {
                        Text("根据 \(userId) 的设置，主题列表被隐藏")
                            .greedyFrame()
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .padding(Spacing.lg)
                            .padding(.bottom, 180)
                            .hide(state.refreshing)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemGroupedBackground))
                    }
                }

                // Bottom Detail Section - Replies
                if currentTab == .reply {
                    ForEach(model.replyInfo.items) { item in
                        ReplyItemView(data: item)
                            .cardScrollTransition()
                            .background {
                                NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                    .opacity(0)
                            }
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemGroupedBackground))
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 1)
            .refreshable {
                await run(action: UserDetailActions.FetchData.Start(id: self.userId))
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                self.scrollY = newValue
            }
            .overlay {
                if state.showProgressView {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }

            // Custom floating nav bar
            customNavBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .task(id: model.avatar) {
            guard !model.avatar.isEmpty, let url = URL(string: model.avatar) else { return }
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data),
                  let color = image.bannerColor else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                dominantColor = SwiftUI.Color(color)
            }
        }
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
    
    private func isSelf() -> Bool {
        AccountState.isSelf(userName: userId)
    }
    
    @ViewBuilder
    private var customNavBar: some View {
        HStack(spacing: Spacing.sm) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .minTapTarget()
            }

            if !shouldHideNavbar {
                AvatarView(url: model.avatar, size: 26)
                Text(model.userName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }

            Spacer()

            if !isSelf() {
                Button {
                    dispatch(UserDetailActions.Follow(id: userId))
                } label: {
                    Image(systemName: state.model.hasFollowed ? "heart.fill" : "heart")
                        .font(.body.weight(.semibold))
                        .minTapTarget()
                }

                Button {
                    dispatch(UserDetailActions.BlockUser(id: userId))
                } label: {
                    Image(systemName: state.model.hasBlocked ? "eye.slash.fill" : "eye.slash")
                        .font(.body.weight(.semibold))
                        .minTapTarget()
                }
            }
        }
        .foregroundColor(shouldHideNavbar ? .white : .primary)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.xs)
        .padding(.bottom, Spacing.xs)
        .frame(maxWidth: .infinity)
        .background {
            if !shouldHideNavbar {
                Rectangle()
                    .fill(.bar)
                    .ignoresSafeArea(edges: .top)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: shouldHideNavbar)
    }

    @ViewBuilder
    private var topBannerView: some View {
        VStack (spacing: Spacing.md) {
            Color.clear.frame(height: 34)
            AvatarView(url: model.avatar, size: heightOfNodeImage)
            HStack(alignment: .center, spacing: Spacing.xs) {
                Circle()
                    .fill(state.model.isOnline ? .green : Color.secondaryText)
                    .frame(width: 8, height: 8)
                Text(model.userName)
                    .font(.title3.weight(.bold))
            }
            Button {
                dispatch(UserDetailActions.Follow(id: userId))
            } label: {
                Text(state.model.hasFollowed ? "已关注" : "关注")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.xs + 2)
                    .background(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
            }
            .hide(isSelf())
            Text(model.desc)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
                .foregroundColor(.white.opacity(0.8))
        }
        .foregroundColor(.white)
    }

    private var tabsTitleView: some View {
        HStack(spacing: 0) {
            TabButton(title: "主题", id: .topic, selectedID: $currentTab, animation: self.animation)
            TabButton(title: "回复", id: .reply, selectedID: $currentTab, animation: self.animation)
        }
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
    


    struct ReplyItemView: View {
        var data: UserDetailInfo.ReplyInfo.Item
        let quoteFont = Style.font(UIFont.prfered(.footnote))
            .foregroundColor(Color.primaryText.uiColor)

        var body: some View {
            VStack(spacing: 0) {
                Text(data.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryText)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                RichText {
                    data.content
                        .rich(baseStyle: quoteFont)
                }
                .font(.footnote)
                .padding(Spacing.md)
                .background {
                    HStack(spacing: 0) {
                        Color.accentColor
                            .frame(width: 3)
                        Color(.tertiarySystemFill)
                    }
                    .clipCorner(1.5, corners: [.topLeft, .bottomLeft])
                }
                .padding(.vertical, Spacing.xs + 2)
                Text(data.time)
                    .font(AppFont.timestamp)
                    .foregroundColor(.tertiaryText)
                    .greedyWidth(.trailing)
            }
            .padding(Spacing.md)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }


    struct TopicItemView: View {
        var data: UserDetailInfo.TopicInfo.Item

        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(data.userName)
                            .font(AppFont.username)
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        Text(data.time)
                            .font(AppFont.timestamp)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(data.tag)
                        .nodeBadgeStyle()
                }
                Text(data.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryText)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                    .padding(.top, Spacing.sm - 2)
            }
            .padding(Spacing.md)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .contentShape(Rectangle())
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
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isSelected ? .white : .secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background {
                        VStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: CornerRadius.medium)
                                    .fill(Color.accentColor)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }
                        }
                    }
                    .contentShape(Rectangle())
            }
        }
    }

}

//struct UserDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailPage()
//    }
//}
