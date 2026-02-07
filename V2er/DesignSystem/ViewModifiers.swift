//
//  ViewModifiers.swift
//  V2er
//
//  Design token: shared view modifiers replacing duplicate styling patterns.
//

import SwiftUI

// MARK: - Node Badge Modifier

/// Replaces the 5+ duplicate node-tag styling blocks across the app.
/// Applies consistent padding, background, corner radius, and colors.
struct NodeBadgeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.metadata)
            .foregroundStyle(Color(.secondaryLabel))
            .lineLimit(1)
            .padding(.horizontal, Spacing.sm + 2) // 10pt
            .padding(.vertical, Spacing.sm - 2)   // 6pt
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

extension View {
    /// Apply consistent node/tag badge styling.
    func nodeBadgeStyle() -> some View {
        modifier(NodeBadgeModifier())
    }
}

// MARK: - Load More Modifier

/// Replaces the 8+ identical load-more-indicator patterns.
struct LoadMoreModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView()
            }
            Spacer()
        }
        .frame(height: 50)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.systemBackground))
    }
}

extension View {
    /// Apply standard load-more indicator styling.
    func loadMoreStyle(isLoading: Bool) -> some View {
        modifier(LoadMoreModifier(isLoading: isLoading))
    }
}

// MARK: - Card Scroll Transition

extension View {
    /// Subtle fade + scale as cards approach the viewport edges.
    /// Uses `.visualEffect` which works with List (unlike `.scrollTransition`).
    func cardScrollTransition() -> some View {
        visualEffect { content, proxy in
            let frame = proxy.frame(in: .scrollView(axis: .vertical))

            guard let viewportHeight = proxy.bounds(of: .scrollView(axis: .vertical))?.height else {
                return content
                    .opacity(1)
                    .scaleEffect(1)
            }

            let zone: CGFloat = 100
            let fromBottom = min(1.0, max(0.0, (viewportHeight - frame.minY) / zone))
            let fromTop = min(1.0, max(0.0, frame.maxY / zone))
            let progress = min(fromBottom, fromTop)

            return content
                .opacity(0.7 + 0.3 * progress)
                .scaleEffect(0.96 + 0.04 * progress)
        }
    }
}

// MARK: - Minimum Tap Target

/// Ensures a view meets the 44pt minimum tap target size (Apple HIG).
struct MinTapTargetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
}

extension View {
    /// Ensure minimum 44pt tap target per Apple HIG.
    func minTapTarget() -> some View {
        modifier(MinTapTargetModifier())
    }
}
