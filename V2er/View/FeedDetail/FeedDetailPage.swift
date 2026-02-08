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

struct FeedDetailPage: StateView, KeyboardReadable, InstanceIdentifiable {
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var store: Store
    @State private var selectedImage: UIImage? = nil
    @State private var isUploadingImage = false
    @State private var navigateToBrowserURL: URL? = nil
    @State private var navigateToSafariURL: URL? = nil

    private var useBuiltinBrowser: Bool {
        store.appState.settingState.useBuiltinBrowser
    }

    var bindingState: Binding<FeedDetailState> {
        if store.appState.feedDetailStates[instanceId] == nil {
            store.appState.feedDetailStates[instanceId] = FeedDetailState()
        }
        return $store.appState.feedDetailStates[instanceId]
    }

    var instanceId: String {
        self.id
    }
    @State var isKeyboardVisiable = false
    @State private var isLoadingMore = false
    @State private var contentReady = false
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

    /// 根据当前排序方式返回排序后的回复列表
    private var sortedReplies: [FeedDetailInfo.ReplyInfo.Item] {
        let items = state.model.replyInfo.items
        switch state.replySortType {
        case .byTime:
            return items // 按时间排序（保持原始楼层顺序）
        case .byPopularity:
            // 按点赞数降序，相同点赞数按楼层升序
            return items.sorted { (a, b) in
                if a.loveCount != b.loveCount {
                    return a.loveCount > b.loveCount
                }
                return a.floor < b.floor
            }
        }
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
            .navigationDestination(item: $navigateToBrowserURL) { url in
                InAppBrowserView(url: url)
            }
            .navigationDestination(item: $navigateToSafariURL) { url in
                SafariView(url: url)
                    .ignoresSafeArea()
                    .navigationBarHidden(true)
            }
    }

    @ViewBuilder
    private var contentView: some View {
        listContentView
            .safeAreaInset(edge: .bottom) {
                replyBar
            }
            .navigationTitle("话题")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                moreMenu
            }
        }
        .onChange(of: state.ignored) { ignored in
            if ignored {
                dismiss()
            }
        }
        .onChange(of: state.shouldFocusReply) { shouldFocus in
            if shouldFocus {
                replyIsFocused = true
                store.appState.feedDetailStates[instanceId]?.shouldFocusReply = false
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
    private var moreMenu: some View {
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
                if let url = URL(string: APIService.baseUrlString + "/t/\(id)") {
                    if useBuiltinBrowser {
                        navigateToBrowserURL = url
                    } else {
                        navigateToSafariURL = url
                    }
                }
            } label: {
                Label("使用浏览器打开", systemImage: "safari")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.body)
        }
    }

    @ViewBuilder
    private var listContentView: some View {
        List {
            // Topic Card: Header + Content + Postscripts
            VStack(spacing: 0) {
                AuthorInfoView(initData: initData, data: state.model.headerInfo)

                if !isContentEmpty {
                    NewsContentView(state.model.contentInfo) {
                        withAnimation {
                            contentReady = true
                        }
                    }
                }

                if contentReady || isContentEmpty {
                    ForEach(state.model.postscripts) { postscript in
                        PostscriptItemView(postscript: postscript)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.systemGroupedBackground))

            // Reply Section (shown after content loads)
            if contentReady || isContentEmpty {
                // Reply Section Header
                if !state.model.replyInfo.items.isEmpty {
                    replySectionHeader
                        .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
                }

                // Reply Cards
                ForEach(sortedReplies, id: \.floor) { item in
                    ReplyItemView(info: item, topicId: id)
                        .cardScrollTransition()
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemGroupedBackground))
                }
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
                .listRowBackground(Color(.systemGroupedBackground))
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
        .background(Color(.systemGroupedBackground))
        .environment(\.defaultMinListRowHeight, 1)
        .refreshable {
            await run(action: FeedDetailActions.FetchData.Start(id: instanceId, feedId: initData?.id))
        }
        .onTapGesture {
            replyIsFocused = false
        }
    }

    private var replyBar: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            // Image picker button
            if isUploadingImage {
                ProgressView()
                    .frame(width: 28, height: 28)
                    .padding(.leading, Spacing.xs + 2)
                    .padding(.vertical, 3)
            } else {
                UnifiedImagePickerButton(selectedImage: $selectedImage)
                    .padding(.leading, Spacing.xs + 2)
                    .padding(.vertical, 3)
            }

            MultilineTextField("发表回复", text: bindingState.replyContent)
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
                    .foregroundColor(Color.accentColor.opacity(hasReplyContent ? 1.0 : 0.6))
                    .padding(.trailing, Spacing.xs + 2)
                    .padding(.vertical, 3)
            }
            .disabled(!hasReplyContent)
            .accessibilityLabel("发送回复")
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.sm)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.sm)
        .padding(.bottom, Spacing.sm)
        .onChange(of: selectedImage) { _, newImage in
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
                    // Insert image URL on its own line
                    let currentContent = state.replyContent
                    let prefix = currentContent.isEmpty || currentContent.hasSuffix("\n") ? "" : "\n"
                    store.appState.feedDetailStates[instanceId]?.replyContent += "\(prefix)\(imageUrl)\n"
                    Toast.show("图片上传成功")
                } else {
                    Toast.show(result.error ?? "图片上传失败")
                }
            }
        }
    }

    @ViewBuilder
    private var replySectionHeader: some View {
        HStack(alignment: .center) {
            Text("回复")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primaryText)

            Spacer()

            // Inline sort toggle
            HStack(spacing: Spacing.xxs) {
                ForEach(ReplySortType.allCases, id: \.self) { sortType in
                    let isSelected = state.replySortType == sortType
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.appState.feedDetailStates[instanceId]?.replySortType = sortType
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: sortType.iconName)
                                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                            Text(sortType.displayName)
                                .font(.caption.weight(isSelected ? .semibold : .regular))
                        }
                        .foregroundColor(isSelected ? .primaryText : .tertiaryText)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(isSelected ? Color(.systemGray5) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    @ViewBuilder
    private var actionBar: some View {
        HStack (spacing: Spacing.md) {
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
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.lg)
    }

}
