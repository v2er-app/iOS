//
//  FeedDetailPlaceholder.swift
//  V2er
//
//  Redacted placeholder shown while FeedDetailPage is loading.
//

import SwiftUI

struct FeedDetailPlaceholder: View {
    /// Approximate heights used to compute how many reply cards fill the screen.
    private static let topicCardHeight: CGFloat = 280
    private static let replyCardHeight: CGFloat = 110
    private static let navBarHeight: CGFloat = 100

    private var replyCount: Int {
        #if os(iOS)
        let screenHeight = UIScreen.main.bounds.height
        #else
        let screenHeight: CGFloat = 900
        #endif
        let remaining = screenHeight - Self.navBarHeight - Self.topicCardHeight
        return max(2, Int(ceil(remaining / Self.replyCardHeight)))
    }

    var body: some View {
        // Topic card
        VStack(spacing: 0) {
            // Author info
            HStack(alignment: .top) {
                Circle()
                    .frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: Spacing.xs + 2) {
                    Text("placeholder")
                        .lineLimit(1)
                    Text("placeholder text here")
                        .lineLimit(1)
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                }
                Spacer()
                Text("Node")
                    .nodeBadgeStyle()
            }
            // Title
            Text("This is a placeholder title text for loading")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .padding(.top, Spacing.lg)
            // Content lines
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Content placeholder line one that is pretty long and fills the width")
                Text("Content placeholder line two with moderate length text here")
                Text("Content line three shorter")
                Text("Content placeholder line four also fills the width of the screen")
                Text("Content line five is a bit shorter than the rest")
                Text("Content placeholder line six medium")
            }
            .font(.callout)
            .greedyWidth(.leading)
            .padding(.top, Spacing.md)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.systemGroupedBackground))

        // Reply placeholders — count adapts to screen height
        ForEach(0..<replyCount, id: \.self) { _ in
            replyPlaceholder
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
        }
    }

    private var replyPlaceholder: some View {
        HStack(alignment: .top) {
            Circle()
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("username")
                    Text("3 hours ago")
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                }
                Text("Reply content placeholder that spans a couple of lines of text")
                    .font(.callout)
            }
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}
