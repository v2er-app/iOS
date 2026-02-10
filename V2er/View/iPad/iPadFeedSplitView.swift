//
//  iPadFeedSplitView.swift
//  V2er
//
//  Two-pane layout for the Feed tab on iPad.
//  Left pane: feed list, right pane: feed detail.
//

import SwiftUI

struct iPadFeedSplitView: View {
    var selecedTab: TabId
    @State private var detailRoute: AppRoute?
    @State private var detailPath = NavigationPath()

    /// Extract the feed ID from detailRoute for highlighting the selected feed in the list.
    private var selectedFeedId: String? {
        if case .feedDetail(let id) = detailRoute { return id }
        return nil
    }

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 700 {
                twoColumnLayout(totalWidth: geo.size.width)
            } else {
                singleColumnLayout
            }
        }
    }

    // MARK: - Two-Column (iPad landscape)

    private var feedPage: some View {
        FeedPage(
            selecedTab: selecedTab,
            onSelectFeed: { feedId in
                detailRoute = .feedDetail(id: feedId)
            },
            iPadSelectedFeedId: selectedFeedId
        )
    }

    private func twoColumnLayout(totalWidth: CGFloat) -> some View {
        let leftWidth = min(max(totalWidth * 0.38, 320), 420)
        return HStack(spacing: 0) {
            // Left pane: feed list
            // On macOS, skip NavigationStack to avoid the empty toolbar area;
            // the left pane only shows the list and delegates selection to the right pane.
            #if os(macOS)
            feedPage
                .environmentObject(Store.shared)
                .environment(\.iPadDetailRoute, $detailRoute)
                .frame(width: leftWidth)
            #else
            NavigationStack {
                feedPage
                    .navigationDestination(for: AppRoute.self) { $0.destination() }
            }
            .environmentObject(Store.shared)
            .environment(\.iPadDetailRoute, $detailRoute)
            .frame(width: leftWidth)
            #endif

            #if os(iOS)
            Divider()
            #endif

            // Right pane: detail or placeholder.
            // Uses NavigationStack(path:) for programmatic stack control.
            // .id(detailRoute) on the inner Group recreates the root content
            // when left-pane selection changes, WITHOUT destroying the
            // NavigationStack itself (which would break push navigation).
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
            .environmentObject(Store.shared)
            .environment(\.iPadDetailPath, $detailPath)
            .onChange(of: detailRoute) { _, _ in
                detailPath = NavigationPath()
            }
        }
    }

    // MARK: - Single-Column (iPad portrait / narrow)

    private var singleColumnLayout: some View {
        NavigationStack {
            FeedPage(selecedTab: selecedTab)
                .navigationDestination(for: AppRoute.self) { $0.destination() }
        }
        .environmentObject(Store.shared)
    }

    // MARK: - Placeholder

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("选择一个帖子")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
