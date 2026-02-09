//
//  iPadTabSplitView.swift
//  V2er
//
//  Reusable two-column split view for iPad tabs (Explore, Message, Me).
//  Mirrors the iPadFeedSplitView pattern but works with any list content.
//

import SwiftUI

struct iPadTabSplitView<Content: View>: View {
    let placeholderIcon: String
    let placeholderText: String
    @ViewBuilder let content: () -> Content

    @State private var detailRoute: AppRoute?
    @State private var detailPath = NavigationPath()

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 700 {
                twoColumnLayout(totalWidth: geo.size.width)
            } else {
                singleColumnLayout
            }
        }
    }

    // MARK: - Two-Column (iPad landscape / wide)

    private func twoColumnLayout(totalWidth: CGFloat) -> some View {
        let leftWidth = min(max(totalWidth * 0.38, 320), 420)
        return HStack(spacing: 0) {
            // Left pane: list content
            NavigationStack {
                content()
                    .navigationDestination(for: AppRoute.self) { $0.destination() }
            }
            .environment(\.iPadDetailRoute, $detailRoute)
            .frame(width: leftWidth)

            Divider()

            // Right pane: detail or placeholder
            NavigationStack(path: $detailPath) {
                Group {
                    if let route = detailRoute {
                        route.destination()
                    } else {
                        placeholderView
                    }
                }
                .id(detailRoute)
                .navigationDestination(for: AppRoute.self) { $0.destination() }
            }
            .environment(\.iPadDetailPath, $detailPath)
            .onChange(of: detailRoute) { _, _ in
                detailPath = NavigationPath()
            }
        }
    }

    // MARK: - Single-Column (narrow / portrait)

    private var singleColumnLayout: some View {
        NavigationStack {
            content()
                .navigationDestination(for: AppRoute.self) { $0.destination() }
        }
    }

    // MARK: - Placeholder

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: placeholderIcon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(placeholderText)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
