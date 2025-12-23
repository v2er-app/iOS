//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import SafariServices
import PhotosUI

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct FeedDetailPage: StateView, KeyboardReadable, InstanceIdentifiable {
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var store: Store
    @State private var showingSafari = false
    @State private var safariURL: URL?
    @State private var showingMobileWeb = false
    @State private var mobileWebURL: URL?
    @State private var selectedImage: UIImage? = nil
    @State private var isUploadingImage = false

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
    @State private var isLoadingMore = false
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

    private func shareTopicContent() {
        let title = state.model.headerInfo?.title ?? "V2EX 话题"
        let urlString = APIService.baseUrlString + "/t/\(id)"
        guard let shareURL = URL(string: urlString) else {
            Toast.show("分享链接生成失败")
            return
        }
        let activityItems: [Any] = [title, shareURL]

        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // For iPad, we need to provide a source view
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            rootVC.present(activityVC, animated: true)
        } else {
            Toast.show("无法打开分享")
        }
    }

    var body: some View {
        contentView
            .sheet(isPresented: $showingSafari) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $showingMobileWeb) {
                if let url = mobileWebURL {
                    MobileWebView(url: url)
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            listContentView
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
            guard !isPresented else { return }
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

    @ViewBuilder
    private var listContentView: some View {
        List {
            // Header Section
            AuthorInfoView(initData: initData, data: state.model.headerInfo)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.itemBg)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("listScroll")).minY
                        )
                    }
                )

            // Content Section
            if !isContentEmpty {
                NewsContentView(state.model.contentInfo)
                    .padding(.horizontal, 10)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.itemBg)
            }

            // Postscripts Section (附言)
            ForEach(state.model.postscripts) { postscript in
                PostscriptItemView(postscript: postscript)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.itemBg)
            }

            // Reply Section
            ForEach(state.model.replyInfo.items) { item in
                ReplyItemView(info: item, topicId: id)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.itemBg)
            }

            // Load More Indicator
            if state.hasMoreData {
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
                .listRowBackground(Color.itemBg)
                .onAppear {
                    guard !isLoadingMore else { return }
                    isLoadingMore = true
                    Task {
                        await run(action: FeedDetailActions.LoadMore.Start(id: instanceId, feedId: initData?.id, willLoadPage: state.willLoadPage))
                        await MainActor.run {
                            isLoadingMore = false
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.itemBg)
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: FeedDetailActions.FetchData.Start(id: instanceId, feedId: initData?.id))
        }
        .onTapGesture {
            replyIsFocused = false
        }
        .coordinateSpace(name: "listScroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            withAnimation {
                hideTitleViews = offset > -100
            }
        }
    }

    private var replyBar: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    // Image picker button
                    if isUploadingImage {
                        ProgressView()
                            .frame(width: 28, height: 28)
                            .padding(.leading, 6)
                            .padding(.vertical, 3)
                    } else {
                        UnifiedImagePickerButton(selectedImage: $selectedImage)
                            .padding(.leading, 6)
                            .padding(.vertical, 3)
                    }

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
                            .foregroundColor(Color.tintColor.opacity(hasReplyContent ? 1.0 : 0.6))
                            .padding(.trailing, 6)
                            .padding(.vertical, 3)
                    }
                    .disabled(!hasReplyContent)
                }
                .background(Color.lightGray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, isKeyboardVisiable ? 0 : topSafeAreaInset().bottom * 0.9)
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .background(Color.itemBg)
        }
        .onChange(of: selectedImage) { newImage in
            guard let image = newImage else { return }
            uploadImage(image)
        }
    }

    private func uploadImage(_ image: UIImage) {
        isUploadingImage = true
        Task {
            let result = await ImgurService.shared.upload(image: image)
            await MainActor.run {
                isUploadingImage = false
                selectedImage = nil
                if result.success, let imageUrl = result.imageUrl {
                    // Save to upload history
                    let record = MyUploadsState.UploadRecord(imageUrl: imageUrl)
                    MyUploadsState.saveUpload(record)
                    // Insert image URL into reply content
                    let currentContent = state.replyContent
                    let imageMarkdown = currentContent.isEmpty ? imageUrl : "\n\(imageUrl)"
                    store.appState.feedDetailStates[instanceId]?.replyContent += imageMarkdown
                    Toast.show("图片上传成功")
                } else {
                    Toast.show(result.error ?? "图片上传失败")
                }
            }
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
                    AvatarView(url: state.model.headerInfo?.avatar ?? .empty, size: 32)
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

                    Divider()

                    // Owner-only actions
                    if let stickyStr = state.model.stickyStr, stickyStr.notEmpty() {
                        Button {
                            dispatch(FeedDetailActions.StickyTopic(id: id))
                        } label: {
                            Label("置顶 10 分钟 (200 铜币)", systemImage: "pin")
                        }
                    }

                    if let fadeStr = state.model.fadeStr, fadeStr.notEmpty() {
                        Button {
                            dispatch(FeedDetailActions.FadeTopic(id: id))
                        } label: {
                            Label("下沉 1 天", systemImage: "arrow.down.to.line")
                        }
                    }

                    // Share button
                    Button {
                        shareTopicContent()
                    } label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        // Use MobileWebView with mobile User-Agent for better mobile experience
                        if let url = URL(string: APIService.baseUrlString + "/t/\(id)") {
                            mobileWebURL = url
                            showingMobileWeb = true
                        }
                    } label: {
                        Label("使用浏览器打开", systemImage: "safari")
                    }
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
}
