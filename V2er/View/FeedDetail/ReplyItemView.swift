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
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme

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
                    Image(systemName: info.hadThanked ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(info.hadThanked ? .red : .secondaryText)
                }

                if #available(iOS 15.0, *) {
                    RichView(htmlContent: info.content)
                        .configuration(compactConfigurationForAppearance())
                        .onLinkTapped { url in
                            Task {
                                await UIApplication.shared.openURL(url)
                            }
                        }
                        .onMentionTapped { username in
                            // TODO: Navigate to user profile
                            print("Mention tapped: @\(username)")
                        }
                } else {
                    // Fallback for iOS 14
                    RichText { info.content }
                }

                Text("\(info.floor)楼")
                    .font(.footnote)
                    .foregroundColor(Color.tintColor)
                Divider()
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 12)
    }

    @available(iOS 15.0, *)
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
