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
    @State private var selectedFeedId: String?

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

    private func twoColumnLayout(totalWidth: CGFloat) -> some View {
        let leftWidth = min(max(totalWidth * 0.38, 320), 420)
        return HStack(spacing: 0) {
            // Left pane: feed list
            NavigationStack {
                FeedPage(
                    selecedTab: selecedTab,
                    onSelectFeed: { feedId in
                        selectedFeedId = feedId
                    },
                    iPadSelectedFeedId: selectedFeedId
                )
                .navigationDestination(for: AppRoute.self) { $0.destination() }
            }
            .frame(width: leftWidth)

            Divider()

            // Right pane: feed detail or placeholder
            NavigationStack {
                if let feedId = selectedFeedId {
                    FeedDetailPage(id: feedId)
                        .navigationDestination(for: AppRoute.self) { $0.destination() }
                } else {
                    placeholderView
                }
            }
            .id(selectedFeedId)
        }
    }

    // MARK: - Single-Column (iPad portrait / narrow)

    private var singleColumnLayout: some View {
        NavigationStack {
            FeedPage(selecedTab: selecedTab)
                .navigationDestination(for: AppRoute.self) { $0.destination() }
        }
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
