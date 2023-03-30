//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedDetailPage: StateView, KeyboardReadable, InstanceIdentifiable {
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var store: Store
    @State var rendered: Bool = false

    var bindingState: Binding<FeedDetailState> {
        if store.appState.feedDetailStates[instanceId] == nil {
            store.appState.feedDetailStates[instanceId] = FeedDetailState()
        }
        return $store.appState.feedDetailStates[instanceId]
    }

    var instanceId: String {
        self.id
    }
    @State var hideTitleViews = true
    @State var isKeyboardVisiable = false
    @FocusState private var replyIsFocused: Bool
    var initData: FeedInfo.Item? = nil
    var id: String

    init(id: String) {
        self.id = id
        self.initData = FeedInfo.Item(id: id)
    }

    init(initData: FeedInfo.Item?) {
        self.initData = initData
        self.id = self.initData!.id
    }

    private var hasReplyContent: Bool {
        !state.replyContent.isEmpty
    }

    private var isContentEmpty: Bool {
        let contentInfo = state.model.contentInfo
        return contentInfo == nil || contentInfo!.html.isEmpty
    }

    private var showProgressView: Bool {
        return state.showProgressView
        || (!isContentEmpty && !self.rendered)
    }
    
    var body: some View {
        contentView
            .navigatable()
    }

    @ViewBuilder
    private var contentView: some View {
        VStack (spacing: 0) {
            // TODO: improve here
            VStack(spacing: 0) {
                AuthorInfoView(initData: initData, data: state.model.headerInfo)
                if !isContentEmpty {
                    NewsContentView(state.model.contentInfo, rendered: $rendered)
                        .padding(.horizontal, 10)
                }
                replayListView
                    .padding(.top, 8)
            }
            .background(showProgressView ? .clear : Color.itemBg)
            .updatable(autoRefresh: showProgressView, hasMoreData: state.hasMoreData) {
                await run(action: FeedDetailActions.FetchData.Start(id: instanceId, feedId: initData?.id))
            } loadMore: {
                await run(action: FeedDetailActions.LoadMore.Start(id: instanceId, feedId: initData?.id, willLoadPage: state.willLoadPage))
            } onScroll: { scrollY in
                withAnimation {
                    hideTitleViews = !(scrollY <= -100)
                }
//                replyIsFocused = false
            }
            .onTapGesture {
                replyIsFocused = false
            }
            replyBar
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            navBar
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)

        .onChange(of: state.ignored) { ignored in
            if ignored {
                dismiss()
            }
        }
        .onAppear {
            dispatch(FeedDetailActions.FetchData.Start(id: instanceId, feedId: initData?.id, autoLoad: !state.hasLoadedOnce))
        }
        .onDisappear {
            if !isPresented {
                log("onPageClosed----->")
                let data: FeedInfo.Item?
                if state.model.headerInfo != nil {
                    data = state.model.headerInfo?.toFeedItemInfo()
                } else {
                    data = initData
                }
                dispatch(MyRecentActions.RecordAction(data: data))
            }
        }
    }

    private var replyBar: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    MultilineTextField("发表回复", text: bindingState.replyContent)
                        .debug()
                        .onReceive(keyboardPublisher) { isKeyboardVisiable in
                            self.isKeyboardVisiable = isKeyboardVisiable
                        }
                        .focused($replyIsFocused)

                    Button {
                        replyIsFocused = false
                        dispatch(FeedDetailActions.ReplyTopic(id: id))
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title.weight(.regular))
                            .foregroundColor(Color.bodyText.opacity(hasReplyContent ? 1.0 : 0.6))
                            .padding(.trailing, 6)
                            .padding(.vertical, 3)
                    }
                    .disabled(!hasReplyContent)
                }
                .background(Color.lightGray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
//                if isKeyboardVisiable {
//                    actionBar
//                        .transition(.opacity)
//                }
            }
            .padding(.bottom, isKeyboardVisiable ? 0 : topSafeAreaInset().bottom * 0.9)
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private var actionBar: some View {
        HStack (spacing: 10) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
                .hapticOnTap()
            Image(systemName: "face.smiling")
                .font(.title2.weight(.regular))
                .hapticOnTap()
            Spacer()
            Button {
                replyIsFocused = false
            } label: {
                Text("完成")
            }
        }
        .greedyWidth()
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var navBar: some View  {
        NavbarHostView(paddingH: 0) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                        .foregroundColor(.tintColor)
                }
                Group {
                    // FIXME: use real value
                    NavigationLink(destination: UserDetailPage(userId: initData?.id ?? .empty)) {
                        AvatarView(url: state.model.headerInfo?.avatar ?? .empty, size: 32)
                    }
                    VStack(alignment: .leading) {
                        Text("话题")
                            .font(.headline)
                        Text(state.model.headerInfo?.title ?? .empty)
                            .font(.subheadline)
                            .greedyWidth(.leading)
                    }
                    .lineLimit(1)
                }
                .opacity(hideTitleViews ? 0.0 : 1.0)
                Menu {
                    let hadStared = state.model.headerInfo?.hadStared ?? false
                    Button {
                        dispatch(FeedDetailActions.StarTopic(id: id))
                    } label: {
                        Label(hadStared ? "取消收藏" : "收藏", systemImage: hadStared ? "bookmark.fill" : "bookmark")
                    }
                    let hadThanked = state.model.headerInfo?.hadThanked ?? false
                    Button {
                        dispatch(FeedDetailActions.ThanksAuthor(id: id))
                    } label: {
                        Label(hadThanked ? "已感谢" : "感谢", systemImage: hadThanked ? "heart.fill" : "heart")
                    }
                    .disabled(hadThanked)

                    Button {
                        dispatch(FeedDetailActions.IgnoreTopic(id: id))
                    } label: {
                        Label("忽略", systemImage: "exclamationmark.octagon")
                    }
                    let reported = state.model.hasReported ?? false
                    Button {
                        replyIsFocused = false
                        dispatch(FeedDetailActions.ReportTopic(id: id))
                    } label: {
                        Label(reported ? "已举报" : "举报", systemImage: "person.crop.circle.badge.exclamationmark")
                    }
                    .disabled(reported)
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .font(.title3.weight(.regular))
                        .foregroundColor(.tintColor)
                }
                .forceClickable()
                .debug(true)
                .hapticOnTap()
            }
            .padding(.vertical, 5)
            .padding(.trailing, 5)
            .overlay {
                Text("话题")
                    .font(.headline)
                    .opacity(hideTitleViews ? 1.0 : 0.0)
            }
            .greedyWidth()
        }
        .visualBlur()
    }
    
    @ViewBuilder
    private var replayListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(state.model.replyInfo.items) { item in
                ReplyItemView(info: item)
            }
        }
    }
    
}

//struct NewsDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedDetailPage(id: .empty)
//            .environmentObject(Store.shared)
//    }
//}
