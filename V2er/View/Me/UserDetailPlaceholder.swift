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
        let bannerHeight: CGFloat = 280
        let tabHeight: CGFloat = 60
        let cardHeight: CGFloat = 100
        return max(2, Int(ceil((screenHeight - bannerHeight - tabHeight) / cardHeight)))
    }

    var body: some View {
        // Banner
        VStack(spacing: Spacing.md) {
            Color.clear.frame(height: 34)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
            Text("username")
                .font(.title3.weight(.bold))
            Text("A short bio description here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .foregroundColor(.white)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.black)

        // Tab selector
        HStack(spacing: 0) {
            Text("Topics")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            Text("Replies")
                .font(.subheadline.weight(.semibold))
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
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("username")
                        .font(AppFont.username)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    Text("3 hours ago")
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
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
