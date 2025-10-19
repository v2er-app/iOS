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
                    Task {
                        await UIApplication.shared.openURL(url)
                    }
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


