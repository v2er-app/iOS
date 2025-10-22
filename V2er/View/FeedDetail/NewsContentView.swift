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
    @Binding var rendered: Bool
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme
    @State private var navigationPath = NavigationPath()

    init(_ contentInfo: FeedDetailInfo.ContentInfo?, rendered: Binding<Bool>) {
        self.contentInfo = contentInfo
        self._rendered = rendered
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            RichView(htmlContent: contentInfo?.html ?? "")
                .configuration(configurationForAppearance())
                .onLinkTapped { url in
                    handleLinkTap(url)
                }
                .onRenderCompleted { metadata in
                    // Mark as rendered after content is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.rendered = true
                    }
                }
                .onRenderFailed { error in
                    print("Render error: \(error)")
                    self.rendered = true
                }

            Divider()
        }
    }

    private func handleLinkTap(_ url: URL) {
        // Smart URL routing - parse V2EX URLs and route accordingly
        let urlString = url.absoluteString
        let path = url.path

        // Check if it's a V2EX internal link
        if let host = url.host, (host.contains("v2ex.com")) {
            // Topic: /t/123456
            if path.contains("/t/"), let topicId = extractTopicId(from: path) {
                print("Navigate to topic: \(topicId)")
                // TODO: Use proper navigation to FeedDetailPage(id: topicId)
                // For now, open in Safari
                UIApplication.shared.open(url)
                return
            }

            // Member: /member/username
            if path.contains("/member/"), let username = extractUsername(from: path) {
                print("Navigate to user: \(username)")
                // TODO: Use proper navigation to UserDetailPage(userId: username)
                // For now, open in Safari
                UIApplication.shared.open(url)
                return
            }

            // Node: /go/nodename
            if path.contains("/go/"), let nodeName = extractNodeName(from: path) {
                print("Navigate to node: \(nodeName)")
                // TODO: Use proper navigation to TagDetailPage
                // For now, open in Safari
                UIApplication.shared.open(url)
                return
            }

            // Other V2EX pages - open in Safari
            UIApplication.shared.open(url)
        } else {
            // External link - open in Safari
            UIApplication.shared.open(url)
        }
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

    private func configurationForAppearance() -> RenderConfiguration {
        var config = RenderConfiguration.default

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


