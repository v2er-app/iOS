//
//  FeedPlaceholder.swift
//  V2er
//
//  Redacted placeholder shown while FeedPage is loading.
//

import SwiftUI

struct FeedPlaceholder: View {
    private var itemCount: Int {
        #if os(iOS)
        let screenHeight = UIScreen.main.bounds.height
        #else
        let screenHeight: CGFloat = 900
        #endif
        let navBarHeight: CGFloat = 100
        let cardHeight: CGFloat = 120
        return max(3, Int(ceil((screenHeight - navBarHeight) / cardHeight)))
    }

    var body: some View {
        ForEach(0..<itemCount, id: \.self) { _ in
            feedItemPlaceholder
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
        }
    }

    private var feedItemPlaceholder: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("username")
                        .font(AppFont.username)
                        .foregroundColor(.primaryText)
                    Text("3 hours ago via iPhone")
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                }
                .lineLimit(1)
                Spacer()
                Text("Node")
                    .nodeBadgeStyle()
            }
            Text("This is a placeholder title for a feed item card")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
                .padding(.top, Spacing.sm - 2)
                .padding(.vertical, Spacing.xs)
            HStack(spacing: Spacing.xxs) {
                Spacer()
                Image(systemName: "bubble.right")
                    .font(AppFont.metadata)
                Text("12")
                    .font(AppFont.metadata)
            }
            .foregroundColor(.secondaryText)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}
