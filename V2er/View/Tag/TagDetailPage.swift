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
        shouldHideNavbar ? .white.opacity(0.9) : .tintColor
    }

    private var statusBarStyle: UIStatusBarStyle {
        shouldHideNavbar ? .lightContent : .darkContent
    }

    var body: some View {
        contentView
            .navigatable()
            .statusBarStyle(statusBarStyle, original: .darkContent)
    }

    @ViewBuilder
    private var contentView: some View {
        ZStack(alignment: .top) {
            navBar
                .zIndex(1)
            VStack(spacing: 0) {
                topBannerView
                    .readSize {
                        bannerViewHeight = $0.height
                    }
                nodeListView
            }
            .loadMore(autoRefresh: state.showProgressView, hasMoreData: state.hasMoreData) {
                await run(action: TagDetailActions.LoadMore.Start(id: instanceId, tagId: tagId, willLoadPage: state.willLoadPage))
            } onScroll: {
                self.scrollY = $0
            }
            .background {
                VStack(spacing: 0) {
                    KFImage
                        .url(URL(string: model.tagImage))
                        .fade(duration: 0.25)
                        .resizable()
                        .blur(radius: 80, opaque: true)
                        .overlay(Color.black.opacity(withAnimation {shouldHideNavbar ? 0.3 : 0.1}))
                        .frame(height: bannerViewHeight * 1.2 + max(scrollY, 0))
                    Spacer()
                }
            }
        }
        .statusBarStyle(shouldHideNavbar ? .lightContent : .darkContent, original: .darkContent)
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
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
                    AvatarView(url: model.tagImage, size: 36)
                    VStack(alignment: .leading) {
                        Text(model.tagName)
                            .font(.headline)
                        Text(model.tagDesc)
                            .font(.subheadline)
                    }
                    .lineLimit(1)
                }
                .opacity(shouldHideNavbar ? 0.0 : 1.0)
                
                Spacer()
                
                Button {
                    // Star the node
                } label: {
                    Image(systemName: "bookmark")
                        .padding(8)
                        .font(.title3.weight(.regular))
                }
                .opacity(shouldHideNavbar ? 0.0 : 1.0)
                .forceClickable()
                
                Button {
                    // Show more actions
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .font(.title3.weight(.regular))
                }
                .forceClickable()
            }
            .padding(.vertical, 5)
        }
        .foregroundColor(foreGroundColor)
        .visualBlur(alpha: shouldHideNavbar ? 0.0 : 1.0)
        .onDisappear {
            if !isPresented {
                log("onPageClosed----->")
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
                        .padding(.horizontal, 15)
                        .padding(.vertical, 2)
                        .cornerBorder(radius: 99, borderWidth: 1, color: foreGroundColor)
                }
                Spacer()
                Text("\(model.countOfStaredPeople)个收藏")
                    .font(.callout)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .foregroundColor(foreGroundColor)
        .foregroundColor(.bodyText)
        .padding(.top, 8)
    }
    
    
    @ViewBuilder
    private var nodeListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(model.topics) { item in
                let data = FeedInfo.Item(
                    id: item.id,
                    title: item.title,
                    avatar: item.avatar)
                NavigationLink(destination: FeedDetailPage(initData: data)) {
                    TagFeedItemView(data: item)
                }
            }
        }
        .background(.white)
        .clipCorner(12, corners: [.topLeft, .topRight])
    }

    struct TagFeedItemView: View {
        var data: TagDetailInfo.Item

        var body: some View {
            VStack(spacing: 0) {
                VStack {
                    HStack(alignment: .top) {
                        NavigationLink(destination: UserDetailPage(userId: data.userName)) {
                            AvatarView(url: data.avatar)
                        }
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
            .background(Color.almostClear)
        }
    }
}


struct TagDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        TagDetailPage()
    }
}
