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
    @ObservedObject private var store = Store.shared
    @State private var scrollY: CGFloat = 0.0
    private let heightOfNodeImage = 60.0
    @State private var bannerViewHeight: CGFloat = 0
    @State private var dominantColor: SwiftUI.Color = .black
    @State private var currentTab: TabButton.ID = .topic
    @State private var navbarVisible = false
    @Namespace var animation
    // FIXME: couldn't be null
    var userId: String = .empty

    private let navShowThreshold: CGFloat = -60
    private let navHideThreshold: CGFloat = -84

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
        !navbarVisible
    }

    #if os(iOS)
    private var statusBarStyle: UIStatusBarStyle {
        shouldHideNavbar ? .lightContent : V2erApp.defaultStatusBarStyle()
    }
    #endif

    var body: some View {
        contentView
            #if os(iOS)
            .statusBarStyle(statusBarStyle)
            #endif
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

                if !state.showProgressView {
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
                            moreTopicsCard
                                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color(.systemGroupedBackground))
                        } else {
                            emptyTopicsView
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
                updateNavbarVisibility(scrollOffset: newValue)
            }
            .overlay {
                if state.showProgressView {
                    List {
                        UserDetailPlaceholder()
                            .redacted(reason: .placeholder)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .environment(\.defaultMinListRowHeight, 1)
                    .scrollDisabled(true)
                    .transition(.opacity.animation(.easeOut(duration: 0.4)))
                }
            }

            // Custom floating nav bar
            customNavBar
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task(id: model.avatar) {
            #if os(iOS)
            guard !model.avatar.isEmpty, let url = URL(string: model.avatar) else { return }
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data),
                  let color = image.bannerColor else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                dominantColor = SwiftUI.Color(color)
            }
            #endif
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

    private func updateNavbarVisibility(scrollOffset: CGFloat) {
        guard bannerViewHeight > 0 else {
            if navbarVisible { navbarVisible = false }
            return
        }
        let relativeOffset = scrollOffset - bannerViewHeight
        let shouldShow: Bool
        if navbarVisible {
            shouldShow = relativeOffset > (bannerViewHeight + navHideThreshold)
        } else {
            shouldShow = relativeOffset > (bannerViewHeight + navShowThreshold)
        }
        if shouldShow != navbarVisible {
            navbarVisible = shouldShow
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

            DataSourceBadge(dataSource: state.dataSource)

            if !isSelf() {
                Menu {
                    Button {
                        dispatch(UserDetailActions.Follow(id: userId))
                    } label: {
                        Label(
                            state.model.hasFollowed ? "取消关注" : "关注",
                            systemImage: state.model.hasFollowed ? "heart.fill" : "heart"
                        )
                    }

                    Button {
                        dispatch(UserDetailActions.BlockUser(id: userId))
                    } label: {
                        Label(
                            state.model.hasBlocked ? "取消屏蔽" : "屏蔽",
                            systemImage: state.model.hasBlocked ? "eye.slash.fill" : "eye.slash"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
                if !isSelf() {
                    Button {
                        dispatch(UserDetailActions.Follow(id: userId))
                    } label: {
                        Text(state.model.hasFollowed ? "已关注" : "关注")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.xs)
                            .background(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
                    }
                }
            }
            Text(model.desc)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, Spacing.lg)
                .foregroundColor(.white.opacity(0.8))
        }
        .foregroundColor(.white)
    }

    private var tabsTitleView: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "主题",
                count: model.topicInfo.items.count,
                id: .topic,
                selectedID: $currentTab,
                animation: self.animation
            )
            TabButton(
                title: "回复",
                count: model.replyInfo.items.count,
                id: .reply,
                selectedID: $currentTab,
                animation: self.animation
            )
        }
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    @ViewBuilder
    private var moreTopicsCard: some View {
        NavigationLink(value: AppRoute.userFeed(userId: userId)) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "arrow.right.circle")
                    .font(.body)
                    .foregroundColor(.accentColor)
                Text("查看 \(userId) 的所有主题")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.accentColor)
                Spacer()
            }
            .padding(Spacing.md)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }

    @ViewBuilder
    private var emptyTopicsView: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "lock.shield")
                .font(.system(size: 44))
                .foregroundColor(.secondaryText)
            Text("主题列表被隐藏")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primaryText)
            Text("根据 \(userId) 的设置，主题列表不可见")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .greedyFrame()
        .padding(Spacing.lg)
        .padding(.bottom, 180)
        .hide(state.refreshing)
    }

    struct ReplyItemView: View {
        var data: UserDetailInfo.ReplyInfo.Item
        let quoteFont = Style.font(PlatformFont.prfered(.footnote))
            .foregroundColor(Color.primaryText.uiColor)

        var body: some View {
            HStack(spacing: 0) {
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
                                .frame(width: 4)
                            Color(.tertiarySystemFill)
                        }
                        .clipCorner(2, corners: [.topLeft, .bottomLeft])
                    }
                    .padding(.vertical, Spacing.xs + 2)
                    Text(data.time)
                        .font(AppFont.timestamp)
                        .foregroundColor(.tertiaryText)
                        .greedyWidth(.trailing)
                }
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.tertiaryText)
                    .padding(.leading, Spacing.sm)
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
                HStack(alignment: .center) {
                    Text(data.time)
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
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
        var count: Int
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
                HStack(spacing: Spacing.xxs) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    if count > 0 {
                        Text("(\(count))")
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                    }
                }
                .foregroundColor(isSelected ? Color(.systemBackground) : .secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(Color.accentColor)
                        .opacity(isSelected ? 1 : 0)
                        .matchedGeometryEffect(id: "TAB", in: animation, isSource: isSelected)
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
