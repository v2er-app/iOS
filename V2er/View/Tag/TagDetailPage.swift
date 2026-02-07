//
//  TagDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/7.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher


struct TagDetailPage: StateView, InstanceIdentifiable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.isPresented) private var isPresented
    @EnvironmentObject private var store: Store
    @State private var isLoadingMore = false
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

    var tag: String?
    var tagId: String?

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
            // Blurred background — edge-to-edge behind status bar
            VStack(spacing: 0) {
                KFImage
                    .url(URL(string: model.tagImage))
                    .fade(duration: 0.25)
                    .resizable()
                    .blur(radius: 60, opaque: true)
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: Color.black.opacity(0.5), location: 0),
                                .init(color: Color.black.opacity(0.35), location: 0.65),
                                .init(color: Color(.systemBackground), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: bannerViewHeight * 1.2 + max(-scrollY, 0))
                Spacer()
            }
            .ignoresSafeArea(edges: .top)

            List {
                // Banner Section
                topBannerView
                    .readSize {
                        bannerViewHeight = $0.height
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                // Node List Section - Each item as separate List row to prevent multiple NavigationLinks triggering
                ForEach(model.topics) { item in
                    TagFeedItemView(data: item)
                        .background {
                            NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                .opacity(0)
                        }
                        .listRowInsets(EdgeInsets(top: Spacing.xxs, leading: Spacing.md, bottom: Spacing.xxs, trailing: Spacing.md))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemBackground))
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
                    .listRowBackground(Color(.systemBackground))
                    .onAppear {
                        guard !isLoadingMore else { return }
                        isLoadingMore = true
                        Task {
                            await run(action: TagDetailActions.LoadMore.Start(id: instanceId, tagId: tagId, willLoadPage: state.willLoadPage))
                            await MainActor.run {
                                isLoadingMore = false
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 1)
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
        .statusBarStyle(shouldHideNavbar ? .lightContent : .darkContent, original: .darkContent)
        .toolbar(.hidden, for: .navigationBar)
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

    @ViewBuilder
    private var customNavBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 34, height: 34)
            }

            Spacer()

            Button {
                dispatch(TagDetailActions.StarNode(id: tagId!))
            } label: {
                Image(systemName: state.model.hasStared ? "bookmark.fill" : "bookmark")
                    .font(.body.weight(.semibold))
                    .frame(width: 34, height: 34)
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
            AvatarView(url: model.tagImage, size: heightOfNodeImage)
            Text(model.tagName)
                .font(.title3.weight(.bold))
            Text(model.tagDesc)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
                .foregroundColor(.white.opacity(0.8))
            HStack {
                Text("\(model.topicsCount)个主题")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                let hadStared = state.model.hasStared
                Button {
                    dispatch(TagDetailActions.StarNode(id: tagId!))
                } label: {
                    Text(hadStared ? "已收藏" : "收藏")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.xs + 2)
                        .background(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
                }
                Spacer()
                Text("\(model.countOfStaredPeople)个收藏")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .foregroundColor(.white)
    }


    struct TagFeedItemView: View {
        var data: TagDetailInfo.Item
        @State private var navigateToRoute: AppRoute?

        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Button {
                        navigateToRoute = .userDetail(userId: data.userName)
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
                }
                Text(data.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryText)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                    .padding(.top, Spacing.sm - 2)
                    .padding(.vertical, Spacing.xs)
                HStack(spacing: Spacing.xxs) {
                    Spacer()
                    Image(systemName: "bubble.right")
                        .font(AppFont.metadata)
                    Text(data.replyCount)
                        .font(AppFont.metadata)
                }
                .foregroundColor(.secondaryText)
            }
            .padding(Spacing.lg)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .contentShape(Rectangle())
            .navigationDestination(item: $navigateToRoute) { route in
                route.destination()
            }
        }
    }
}


struct TagDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        TagDetailPage()
    }
}
