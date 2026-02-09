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
    var onNavigate: ((AppRoute) -> Void)? = nil
    var onOpenSafari: ((URL) -> Void)? = nil
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
    @State private var navigateToRoute: AppRoute? = nil
    @State private var navigateToSafariURL: URL? = nil

    private var useBuiltinBrowser: Bool {
        store.appState.settingState.useBuiltinBrowser
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 0) {
                Button {
                    navigate(to: .userDetail(userId: info.userName))
                } label: {
                    AvatarView(url: info.avatar, size: 36)
                }
                .buttonStyle(.plain)
                Text("楼主")
                    .font(AppFont.ownerBadge)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small - 3))
                    .padding(.top, Spacing.xxs)
                    .hide(!info.isOwner)
            }
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    VStack (alignment: .leading, spacing: Spacing.xs) {
                        Text(info.userName)
                            .foregroundColor(.primaryText)
                        Text(info.time)
                            .font(AppFont.timestamp)
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
                            .font(AppFont.actionIcon)
                            .foregroundColor(info.hadThanked ? .red : .secondaryText)
                    }
                    .disabled(info.hadThanked)
                    .minTapTarget()
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
                        navigate(to: .userDetail(userId: username))
                    }

                Text("\(info.floor)楼")
                    .font(AppFont.metadata)
                    .foregroundColor(.tertiaryText)
            }
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .contentShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "回复") {
            dispatch(FeedDetailActions.ReplyToUser(id: topicId, userName: info.userName))
        }
        .accessibilityAction(named: "感谢") {
            if !info.hadThanked {
                dispatch(FeedDetailActions.ThankReply(id: topicId, replyId: info.replyId, replyUserName: info.userName))
            }
        }
        .contextMenu {
            Button {
                dispatch(FeedDetailActions.ReplyToUser(id: topicId, userName: info.userName))
            } label: {
                Label("回复", systemImage: "arrowshape.turn.up.left")
            }
        }
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
        .navigationDestination(item: $navigateToSafariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
                .navigationBarHidden(true)
        }
    }

    private func navigate(to route: AppRoute) {
        if let onNavigate {
            onNavigate(route)
        } else if let detailRoute = iPadDetailRoute {
            detailRoute.wrappedValue = route
        } else {
            navigateToRoute = route
        }
    }

    private func handleLinkTap(_ url: URL) {
        let action = LinkHandler.action(for: url, useBuiltinBrowser: useBuiltinBrowser)

        switch action {
        case .navigateToTopic(let id):
            navigate(to: .feedDetail(id: id))
        case .navigateToUser(let username):
            navigate(to: .userDetail(userId: username))
        case .navigateToNode(let name):
            navigate(to: .tagDetail(tagId: name))
        case .openInAppBrowser(let browserUrl):
            navigate(to: .inAppBrowser(url: browserUrl))
        case .openInSafariViewController(let webviewUrl):
            openInSafari(webviewUrl)
        }
    }

    private func openInSafari(_ url: URL) {
        if let onOpenSafari {
            onOpenSafari(url)
        } else if let detailRoute = iPadDetailRoute {
            detailRoute.wrappedValue = .safariView(url: url)
        } else {
            navigateToSafariURL = url
        }
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
