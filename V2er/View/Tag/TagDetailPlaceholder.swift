//
//  TagDetailPlaceholder.swift
//  V2er
//
//  Redacted placeholder shown while TagDetailPage is loading.
//

import SwiftUI

struct TagDetailPlaceholder: View {
    private var itemCount: Int {
        #if os(iOS)
        let screenHeight = UIScreen.main.bounds.height
        #else
        let screenHeight: CGFloat = 900
        #endif
        let bannerHeight: CGFloat = 260
        let cardHeight: CGFloat = 130
        return max(2, Int(ceil((screenHeight - bannerHeight) / cardHeight)))
    }

    var body: some View {
        // Banner
        VStack(spacing: Spacing.md) {
            Color.clear.frame(height: 34)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
            Text("Node Name")
                .font(.title3.weight(.bold))
            Text("A brief description of this node topic")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            HStack(spacing: Spacing.sm) {
                Text("128 topics")
                Text("64 favorites")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
            .padding(.bottom, Spacing.lg)
        }
        .foregroundColor(.white)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.black)

        // Topic cards
        ForEach(0..<itemCount, id: \.self) { _ in
            topicPlaceholder
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
        }
    }

    private var topicPlaceholder: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("username")
                        .font(AppFont.username)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    Text("3 hours ago via iPhone")
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                        .greedyWidth(.leading)
                }
                Spacer()
            }
            Text("Placeholder title for a topic card that fills width")
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
                Text("8")
                    .font(AppFont.metadata)
            }
            .foregroundColor(.secondaryText)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}
