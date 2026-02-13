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
        let bannerHeight: CGFloat = 300
        let cardHeight: CGFloat = 130
        return max(2, Int(ceil((screenHeight - bannerHeight) / cardHeight)))
    }

    var body: some View {
        // Banner — with favorite button and icon stats
        VStack(spacing: Spacing.md) {
            Color.clear.frame(height: 34)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
            Text("Node Name")
                .font(.title3.weight(.bold))
            Text("A brief description of this node topic")
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.white.opacity(0.8))
            HStack(spacing: Spacing.lg) {
                Label("128 个主题", systemImage: "text.bubble.fill")
                Label("64 个收藏", systemImage: "star.fill")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
            // Favorite button placeholder
            HStack(spacing: Spacing.xs) {
                Image(systemName: "star")
                    .font(.subheadline)
                Text("收藏")
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.xs + 2)
            .background(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
            .padding(.bottom, Spacing.lg)
        }
        .foregroundColor(.white)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.black)

        // Section header
        SectionTitleView("最新主题", style: .small)
            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.systemGroupedBackground))

        // Topic cards — with reply count in header
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
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "bubble.right")
                        .font(AppFont.metadata)
                    Text("8")
                        .font(AppFont.metadata)
                }
                .foregroundColor(.secondaryText)
            }
            Text("Placeholder title for a topic card that fills width")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
                .padding(.top, Spacing.sm - 2)
                .padding(.vertical, Spacing.xs)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}
