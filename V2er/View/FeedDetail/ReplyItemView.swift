//
//  ReplyListView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Atributika


struct ReplyItemView: View {
    var info: FeedDetailInfo.ReplyInfo.Item
    var topicId: String
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme
    @State private var navigateToUser: String? = nil
    @State private var navigateToTopic: String? = nil
    @State private var navigateToNode: String? = nil
    @State private var navigateToBrowserURL: URL? = nil
    @State private var navigateToSafariURL: URL? = nil

    private var useBuiltinBrowser: Bool {
        store.appState.settingState.useBuiltinBrowser
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 0) {
                AvatarView(url: info.avatar, size: 36)
                    .to { UserDetailPage(userId: info.userName) }
                Text("楼主")
                    .font(.system(size: 8))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .cornerBorder(radius: 3, borderWidth: 0.8, color: .primaryText)
                    .padding(.top, 2)
                    .hide(!info.isOwner)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack (alignment: .leading, spacing: 4) {
                        Text(info.userName)
                            .foregroundColor(.primaryText)
                        Text(info.time)
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                    }
                    Spacer()
                    if info.love.notEmpty() {
                        Text(info.love)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    Button {
                        if !info.hadThanked {
                            dispatch(FeedDetailActions.ThankReply(
                                id: topicId,
                                replyId: info.replyId,
                                replyUserName: info.userName
                            ))
                        }
                    } label: {
                        Image(systemName: info.hadThanked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(info.hadThanked ? .red : .secondaryText)
                    }
                    .disabled(info.hadThanked)
                }

                RichContentView(htmlContent: info.content)
                    .configuration(compactConfigurationForAppearance())
                    .onLinkTapped { url in
                        handleLinkTap(url)
                    }
                    .onImageTapped { url in
                        openInSafari(url)
                    }
                    .onMentionTapped { username in
                        navigateToUser = username
                    }

                Text("\(info.floor)楼")
                    .font(.footnote)
                    .foregroundColor(Color.tintColor)
                Divider()
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                dispatch(FeedDetailActions.ReplyToUser(id: topicId, userName: info.userName))
            } label: {
                Label("回复", systemImage: "arrowshape.turn.up.left")
            }
        }
        .background(
            Group {
                NavigationLink(
                    destination: UserDetailPage(userId: navigateToUser ?? ""),
                    isActive: Binding(
                        get: { navigateToUser != nil },
                        set: { if !$0 { navigateToUser = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()

                NavigationLink(
                    destination: FeedDetailPage(id: navigateToTopic ?? ""),
                    isActive: Binding(
                        get: { navigateToTopic != nil },
                        set: { if !$0 { navigateToTopic = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()

                NavigationLink(
                    destination: TagDetailPage(tagId: navigateToNode ?? ""),
                    isActive: Binding(
                        get: { navigateToNode != nil },
                        set: { if !$0 { navigateToNode = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()

                // Use NavigationLink instead of fullScreenCover for InAppBrowser (iOS 26 bug workaround)
                NavigationLink(
                    destination: Group {
                        if let url = navigateToBrowserURL {
                            InAppBrowserView(url: url)
                        }
                    },
                    isActive: Binding(
                        get: { navigateToBrowserURL != nil },
                        set: { if !$0 { navigateToBrowserURL = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()

                // Use NavigationLink for SafariView (iOS 26 bug workaround)
                NavigationLink(
                    destination: Group {
                        if let url = navigateToSafariURL {
                            SafariView(url: url)
                                .ignoresSafeArea()
                                .navigationBarHidden(true)
                        }
                    },
                    isActive: Binding(
                        get: { navigateToSafariURL != nil },
                        set: { if !$0 { navigateToSafariURL = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
        )
    }

    private func handleLinkTap(_ url: URL) {
        let action = LinkHandler.action(for: url, useBuiltinBrowser: useBuiltinBrowser)

        switch action {
        case .navigateToTopic(let id):
            navigateToTopic = id
        case .navigateToUser(let username):
            navigateToUser = username
        case .navigateToNode(let name):
            navigateToNode = name
        case .openInAppBrowser(let browserUrl):
            navigateToBrowserURL = browserUrl
        case .openInSafariViewController(let webviewUrl):
            openInSafari(webviewUrl)
        }
    }

    private func openInSafari(_ url: URL) {
        navigateToSafariURL = url
    }

    private func compactConfigurationForAppearance() -> RenderConfiguration {
        var config = RenderConfiguration.compact

        // Determine dark mode based on app appearance setting
        let appearance = store.appState.settingState.appearance
        let isDark: Bool
        switch appearance {
        case .dark:
            isDark = true
        case .light:
            isDark = false
        case .system:
            isDark = colorScheme == .dark
        }

        // Adjust stylesheet for dark mode
        if isDark {
            config.stylesheet.body.color = .adaptive(light: .black, dark: .white)
            config.stylesheet.link.color = .adaptive(light: .blue, dark: Color(red: 0.4, green: 0.6, blue: 1.0))
            config.stylesheet.mention.textColor = .adaptive(light: Color(red: 0.2, green: 0.4, blue: 0.8), dark: Color(red: 0.4, green: 0.6, blue: 1.0))
        }

        return config
    }
}
