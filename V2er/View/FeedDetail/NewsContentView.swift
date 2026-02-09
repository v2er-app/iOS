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
    var onNavigate: ((AppRoute) -> Void)? = nil
    var onOpenSafari: ((URL) -> Void)? = nil
    var onContentReady: (() -> Void)?
    @ObservedObject private var store = Store.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
    @State private var navigateToRoute: AppRoute? = nil
    @State private var navigateToSafariURL: URL? = nil

    private var useBuiltinBrowser: Bool {
        store.appState.settingState.useBuiltinBrowser
    }

    init(_ contentInfo: FeedDetailInfo.ContentInfo?, onNavigate: ((AppRoute) -> Void)? = nil, onOpenSafari: ((URL) -> Void)? = nil, onContentReady: (() -> Void)? = nil) {
        self.contentInfo = contentInfo
        self.onNavigate = onNavigate
        self.onOpenSafari = onOpenSafari
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
        }
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
        .navigationDestination(item: $navigateToSafariURL) { url in
            #if os(iOS)
            SafariView(url: url)
                .ignoresSafeArea()
                .navigationBarHidden(true)
            #else
            InAppBrowserView(url: url)
            #endif
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
