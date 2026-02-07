//
//  TagDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/7.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher

private struct TagDetailScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

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
        return scrollY > -heightOfNodeImage * 1.0
    }

    private var foreGroundColor: Color {
        shouldHideNavbar ? Color.primaryText.opacity(0.9) : .accentColor
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
                                key: TagDetailScrollOffsetKey.self,
                                value: geometry.frame(in: .named("tagDetailScroll")).minY
                            )
                        }
                    )

                // Node List Section - Each item as separate List row to prevent multiple NavigationLinks triggering
                ForEach(model.topics) { item in
                    TagFeedItemView(data: item)
                        .background {
                            NavigationLink(value: AppRoute.feedDetail(id: item.id)) { EmptyView() }
                                .opacity(0)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
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
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
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
            .coordinateSpace(name: "tagDetailScroll")
            .onPreferenceChange(TagDetailScrollOffsetKey.self) { offset in
                self.scrollY = offset
            }
            .background {
                VStack(spacing: 0) {
                    KFImage
                        .url(URL(string: model.tagImage))
                        .fade(duration: 0.25)
                        .resizable()
                        .blur(radius: 80, opaque: true)
                        .overlay(Color.dynamic(light: .black, dark: .white).opacity(withAnimation {shouldHideNavbar ? 0.3 : 0.1}))
                        .frame(height: bannerViewHeight * 1.2 + max(scrollY, 0))
                    Spacer()
                }
            }
            .overlay {
                if state.showProgressView {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
        .statusBarStyle(shouldHideNavbar ? .lightContent : .darkContent, original: .darkContent)
        .navigationTitle(model.tagName.isEmpty ? "节点" : model.tagName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dispatch(TagDetailActions.StarNode(id: tagId!))
                } label: {
                    Image(systemName: state.model.hasStared ? "bookmark.fill" : "bookmark")
                }
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
    private var topBannerView: some View {
        VStack (spacing: 14) {
            Color.clear.frame(height: topSafeAreaInset().top)
            AvatarView(url: model.tagImage, size: heightOfNodeImage)
            Text(model.tagName)
                .font(.headline.weight(.semibold))
            Text(model.tagDesc)
                .font(.callout)
                .padding(.horizontal, 10)
            HStack {
                Text("\(model.topicsCount)个主题")
                    .font(.callout)
                Spacer()
                let hadStared = state.model.hasStared
                Button {
                    dispatch(TagDetailActions.StarNode(id: tagId!))
                } label: {
                    Text(hadStared ? "已收藏" : "收藏")
                        .font(.callout)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.xxs)
                        .background(Capsule().stroke(foreGroundColor, lineWidth: 1))
                }
                Spacer()
                Text("\(model.countOfStaredPeople)个收藏")
                    .font(.callout)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
        .foregroundColor(foreGroundColor)
        .foregroundColor(Color(.label))
        .padding(.top, 8)
    }
    
    
    struct TagFeedItemView: View {
        var data: TagDetailInfo.Item
        @State private var navigateToRoute: AppRoute?

        var body: some View {
            VStack(spacing: 0) {
                VStack {
                    HStack(alignment: .top) {
                        Button {
                            navigateToRoute = .userDetail(userId: data.userName)
                        } label: {
                            AvatarView(url: data.avatar)
                        }
                        .buttonStyle(.plain)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(data.userName)
                                .lineLimit(1)
                            Text(data.timeAndReplier)
                                .font(.footnote)
                                .greedyWidth(.leading)
                        }
                        Spacer()
                    }
                    Text(data.title )
                        .greedyWidth(.leading)
                        .lineLimit(2)
                    Text("评论\(data.replyCount)")
                        .lineLimit(1)
                        .font(.footnote)
                        .greedyWidth(.trailing)
                }
                .padding(12)
                Divider()
            }
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
