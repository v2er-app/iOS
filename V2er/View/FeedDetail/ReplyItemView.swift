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
    @State private var showingSafari = false
    @State private var safariURL: URL?
    @State private var navigateToUser: String? = nil

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
        .sheet(isPresented: $showingSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
        .background(
            NavigationLink(
                destination: Group {
                    if let username = navigateToUser {
                        UserDetailPage(userId: username)
                    }
                },
                isActive: Binding(
                    get: { navigateToUser != nil },
                    set: { if !$0 { navigateToUser = nil } }
                )
            ) {
                EmptyView()
            }
            .hidden()
        )
    }

    private func handleLinkTap(_ url: URL) {
        // Smart URL routing - parse V2EX URLs and route accordingly
        let path = url.path

        // Check if it's a V2EX internal link
        if let host = url.host, (host.contains("v2ex.com")) {
            // Topic: /t/123456
            if path.contains("/t/"), let topicId = extractTopicId(from: path) {
                print("Navigate to topic: \(topicId)")
                // TODO: Use proper navigation to FeedDetailPage(id: topicId)
                openInSafari(url)
                return
            }

            // Member: /member/username
            if path.contains("/member/"), let username = extractUsername(from: path) {
                print("Navigate to user: \(username)")
                // TODO: Use proper navigation to UserDetailPage(userId: username)
                openInSafari(url)
                return
            }

            // Node: /go/nodename
            if path.contains("/go/"), let nodeName = extractNodeName(from: path) {
                print("Navigate to node: \(nodeName)")
                // TODO: Use proper navigation to TagDetailPage
                openInSafari(url)
                return
            }

            // Other V2EX pages - open in SafariView
            openInSafari(url)
        } else {
            // External link - open in SafariView (stays in app)
            openInSafari(url)
        }
    }

    private func openInSafari(_ url: URL) {
        safariURL = url
        showingSafari = true
    }

    private func extractTopicId(from path: String) -> String? {
        let pattern = "/t/(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: path, range: NSRange(path.startIndex..., in: path)),
              let range = Range(match.range(at: 1), in: path) else {
            return nil
        }
        return String(path[range])
    }

    private func extractUsername(from path: String) -> String? {
        let components = path.components(separatedBy: "/")
        guard let memberIndex = components.firstIndex(of: "member"),
              memberIndex + 1 < components.count else {
            return nil
        }
        return components[memberIndex + 1]
    }

    private func extractNodeName(from path: String) -> String? {
        let components = path.components(separatedBy: "/")
        guard let goIndex = components.firstIndex(of: "go"),
              goIndex + 1 < components.count else {
            return nil
        }
        return components[goIndex + 1]
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
