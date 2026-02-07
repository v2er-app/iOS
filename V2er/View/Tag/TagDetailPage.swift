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
    @State private var dominantColor: Color = .black

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
            // Dominant color gradient background — edge-to-edge behind status bar
            VStack(spacing: 0) {
                LinearGradient(
                    stops: [
                        .init(color: dominantColor, location: 0),
                        .init(color: dominantColor, location: 0.85),
                        .init(color: Color(.systemGroupedBackground), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: max(bannerViewHeight * 1.5, UIScreen.main.bounds.height) + max(-scrollY, 0))
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

                // Content sheet header — rounded top edge overlapping the banner gradient
                if !model.topics.isEmpty {
                    Color(.systemGroupedBackground)
                        .frame(height: CornerRadius.large)
                        .clipCorner(CornerRadius.large, corners: [.topLeft, .topRight])
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }

                // Node List Section - Each item as separate List row to prevent multiple NavigationLinks triggering
                ForEach(model.topics) { item in
                    TagFeedItemView(data: item)
                        .cardScrollTransition()
                        .background {
                            NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                .opacity(0)
                        }
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
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
        .task(id: model.tagImage) {
            guard !model.tagImage.isEmpty, let url = URL(string: model.tagImage) else { return }
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data),
                  let color = image.bannerColor else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                dominantColor = Color(color)
            }
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
            Text(model.tagDesc)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
                .foregroundColor(.white.opacity(0.8))
            HStack(spacing: Spacing.sm) {
                Text("\(model.topicsCount)个主题")
                Circle()
                    .frame(width: 3, height: 3)
                Text("\(model.countOfStaredPeople)个收藏")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
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
            .padding(Spacing.md)
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
