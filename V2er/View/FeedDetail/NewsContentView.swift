//
//  NewsContentView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsContentView: View {
    var contentInfo: FeedDetailInfo.ContentInfo?
    var onContentReady: (() -> Void)?
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme
    @State private var navigateToTopic: String? = nil
    @State private var navigateToUser: String? = nil
    @State private var navigateToNode: String? = nil
    @State private var navigateToBrowserURL: URL? = nil
    @State private var navigateToSafariURL: URL? = nil

    private var useBuiltinBrowser: Bool {
        store.appState.settingState.useBuiltinBrowser
    }

    init(_ contentInfo: FeedDetailInfo.ContentInfo?, onContentReady: (() -> Void)? = nil) {
        self.contentInfo = contentInfo
        self.onContentReady = onContentReady
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            RichContentView(htmlContent: contentInfo?.html ?? "")
                .configuration(configurationForAppearance())
                .onLinkTapped { url in
                    handleLinkTap(url)
                }
                .onImageTapped { url in
                    // Open image in SafariView for now
                    openInSafari(url)
                }
                .onRenderCompleted { _ in
                    onContentReady?()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()
        }
        .background(
            Group {
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

    private func configurationForAppearance() -> RenderConfiguration {
        // Use V2EX stylesheet which has heading sizes matching Android
        var config = RenderConfiguration(stylesheet: .v2ex)

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
            config.stylesheet.heading.color = .adaptive(light: .black, dark: .white)
            config.stylesheet.link.color = .adaptive(light: .blue, dark: Color(red: 0.4, green: 0.6, blue: 1.0))
        }

        return config
    }
}


