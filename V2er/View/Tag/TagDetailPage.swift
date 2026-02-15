//
//  TagDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/7.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI


struct TagDetailPage: StateView, InstanceIdentifiable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.isPresented) private var isPresented
    @ObservedObject private var store = Store.shared
    @State private var isLoadingMore = false
    @State private var showFullDescription = false
    var instanceId: String {
        tagId ?? .default
    }

    var bindingState: Binding<TagDetailState> {
        if store.appState.tagDetailStates[instanceId] == nil {
            store.appState.tagDetailStates[instanceId] = TagDetailState()
        }
        return $store.appState.tagDetailStates[instanceId]
    }

    var model: TagDetailInfo {
        state.model
    }

    @State private var scrollY: CGFloat = 0.0
    private let heightOfNodeImage = 60.0
    @State private var bannerViewHeight: CGFloat = 0
    @State private var dominantColor: Color = .black
    @State private var navbarVisible = false

    private let navShowThreshold: CGFloat = -60
    private let navHideThreshold: CGFloat = -84

    var tag: String?
    var tagId: String?

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
                let endColor = model.topics.isEmpty ? dominantColor : Color(.systemGroupedBackground)
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
                .animation(.easeInOut(duration: 0.3), value: model.topics.isEmpty)
                endColor
            }
            .ignoresSafeArea(edges: .top)

            List {
                // Banner Section (includes rounded corner cap at bottom)
                topBannerView
                    .readSize {
                        bannerViewHeight = $0.height
                    }
                    .padding(.bottom, model.topics.isEmpty ? 0 : 35)
                    .background(alignment: .bottom) {
                        if !model.topics.isEmpty {
                            Color(.systemGroupedBackground)
                                .frame(height: 30)
                                .clipCorner(30, corners: [.topLeft, .topRight])
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                // Section header
                if !model.topics.isEmpty {
                    SectionTitleView("最新主题", style: .small)
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
                }

                // Node List Section - Each item as separate List row to prevent multiple NavigationLinks triggering
                ForEach(Array(model.topics.enumerated()), id: \.element.id) { index, item in
                    TagFeedItemView(data: item)
                        .cardScrollTransition()
                        .background {
                            NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                .opacity(0)
                        }
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
                        .onAppear {
                            if index == model.topics.count - 3 {
                                triggerLoadMore()
                            }
                        }
                }

                // Load More Indicator
                if state.hasMoreData && !model.topics.isEmpty {
                    HStack {
                        Spacer()
                        if isLoadingMore {
                            ProgressView()
                        }
                        Spacer()
                    }
                    .frame(height: 50)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemGroupedBackground))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 1)
            .refreshable {
                await run(action: TagDetailActions.LoadMore.Start(id: instanceId, tagId: tagId, willLoadPage: 1))
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
                        TagDetailPlaceholder()
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
        .statusBarStyle(shouldHideNavbar ? .lightContent : V2erApp.defaultStatusBarStyle())
        #endif
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task(id: model.tagImage) {
            #if os(iOS)
            guard !model.tagImage.isEmpty, let url = URL(string: model.tagImage) else { return }
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data),
                  let color = image.bannerColor else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                dominantColor = Color(color)
            }
            #endif
        }
        .onAppear {
            dispatch(TagDetailActions.LoadMore.Start(id: instanceId, tagId: tagId, autoLoad: !state.hasLoadedOnce))
        }
        .onDisappear {
            if !isPresented {
                log("onPageClosed----->")
                // dispatch(InstanceDestoryAction(target: .userdetail, id: instanceId))
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

    private func triggerLoadMore() {
        guard state.hasMoreData, !isLoadingMore else { return }
        isLoadingMore = true
        Task {
            await run(action: TagDetailActions.LoadMore.Start(id: instanceId, tagId: tagId, willLoadPage: state.willLoadPage))
            await MainActor.run {
                isLoadingMore = false
            }
        }
    }

    @ViewBuilder
    private var customNavBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .minTapTarget()
            }

            if !shouldHideNavbar {
                AvatarView(url: model.tagImage, size: 26)
                Text(model.tagName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }

            Spacer()

            DataSourceBadge(dataSource: state.dataSource)

            Button {
                guard let tagId = tagId else { return }
                dispatch(TagDetailActions.StarNode(id: tagId))
            } label: {
                Image(systemName: state.model.hasStared ? "bookmark.fill" : "bookmark")
                    .font(.body.weight(.semibold))
                    .minTapTarget()
            }
            .disabled(tagId == nil)
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
            AvatarView(url: model.tagImage, size: heightOfNodeImage)
            Text(model.tagName)
                .font(.title3.weight(.bold))
            Group {
                Text(model.tagDesc)
                    .lineLimit(showFullDescription ? nil : 3)
                if model.tagDesc.count > 80 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showFullDescription.toggle()
                        }
                    } label: {
                        Text(showFullDescription ? "收起" : "展开")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.lg)
            .foregroundColor(.white.opacity(0.8))
            HStack(spacing: Spacing.lg) {
                Label("\(model.topicsCount) 个主题", systemImage: "text.bubble.fill")
                Label("\(model.countOfStaredPeople) 个收藏", systemImage: "star.fill")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
            Button {
                guard let tagId = tagId else { return }
                dispatch(TagDetailActions.StarNode(id: tagId))
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: state.model.hasStared ? "star.fill" : "star")
                        .font(.subheadline)
                    Text(state.model.hasStared ? "已收藏" : "收藏")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xs + 2)
                .background(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
            }
            .disabled(tagId == nil)
            .padding(.bottom, Spacing.lg)
        }
        .foregroundColor(.white)
    }


    struct TagFeedItemView: View {
        var data: TagDetailInfo.Item
        @Environment(\.iPadDetailRoute) private var iPadDetailRoute
        @State private var navigateToRoute: AppRoute?

        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Button {
                        navigate(to: .userDetail(userId: data.userName))
                    } label: {
                        AvatarView(url: data.avatar)
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(data.userName)
                            .font(AppFont.username)
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        Text(data.timeAndReplier)
                            .font(AppFont.timestamp)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                            .greedyWidth(.leading)
                    }
                    Spacer()
                    if !data.replyCount.isEmpty && data.replyCount != "0" {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "bubble.right")
                                .font(AppFont.metadata)
                            Text(data.replyCount)
                                .font(AppFont.metadata)
                        }
                        .foregroundColor(.secondaryText)
                    }
                }
                Text(data.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryText)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                    .padding(.top, Spacing.sm - 2)
                    .padding(.vertical, Spacing.xs)
            }
            .padding(Spacing.md)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .contentShape(Rectangle())
            .navigationDestination(item: $navigateToRoute) { route in
                route.destination()
            }
        }

        private func navigate(to route: AppRoute) {
            if let detailRoute = iPadDetailRoute {
                detailRoute.wrappedValue = route
            } else {
                navigateToRoute = route
            }
        }
    }
}


struct TagDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        TagDetailPage()
    }
}
