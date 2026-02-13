//
//  UserDetailPlaceholder.swift
//  V2er
//
//  Redacted placeholder shown while UserDetailPage is loading.
//

import SwiftUI

struct UserDetailPlaceholder: View {
    private var itemCount: Int {
        #if os(iOS)
        let screenHeight = UIScreen.main.bounds.height
        #else
        let screenHeight: CGFloat = 900
        #endif
        let bannerHeight: CGFloat = 240
        let tabHeight: CGFloat = 60
        let cardHeight: CGFloat = 80
        return max(2, Int(ceil((screenHeight - bannerHeight - tabHeight) / cardHeight)))
    }

    var body: some View {
        // Banner — compact layout with inline follow button
        VStack(spacing: Spacing.md) {
            Color.clear.frame(height: 34)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
            HStack(alignment: .center, spacing: Spacing.xs) {
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
                Text("username")
                    .font(.title3.weight(.bold))
                Text("关注")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xs)
                    .background(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
            }
            Text("A short bio description here")
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.white.opacity(0.8))
        }
        .foregroundColor(.white)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.black)

        // Tab selector with counts
        HStack(spacing: 0) {
            HStack(spacing: Spacing.xxs) {
                Text("主题")
                    .font(.subheadline.weight(.semibold))
                Text("(5)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
            }
            .foregroundColor(.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            HStack(spacing: Spacing.xxs) {
                Text("回复")
                    .font(.subheadline.weight(.semibold))
                Text("(3)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
            }
            .foregroundColor(.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
        }
        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.systemGroupedBackground))

        // Topic cards — simplified layout (no username, just timestamp + node)
        ForEach(0..<itemCount, id: \.self) { _ in
            topicPlaceholder
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.sm, bottom: Spacing.xs, trailing: Spacing.sm))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
        }
    }

    private var topicPlaceholder: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("3 hours ago")
                    .font(AppFont.timestamp)
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
                Spacer()
                Text("Node")
                    .nodeBadgeStyle()
            }
            Text("Placeholder topic title spans two lines of text here")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
                .padding(.top, Spacing.sm - 2)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}
