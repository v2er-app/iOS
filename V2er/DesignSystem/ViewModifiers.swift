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
    /// Scroll-driven fade + scale as cards approach the viewport edges.
    /// Falls back to global coordinates when scroll-view bounds are unavailable (e.g. inside List).
    func cardScrollTransition() -> some View {
        visualEffect { content, proxy in
            let frame: CGRect
            let viewportHeight: CGFloat

            if let scrollBounds = proxy.bounds(of: .scrollView(axis: .vertical)) {
                frame = proxy.frame(in: .scrollView(axis: .vertical))
                viewportHeight = scrollBounds.height
            } else {
                frame = proxy.frame(in: .global)
                viewportHeight = UIScreen.main.bounds.height
            }

            guard !frame.isEmpty else {
                return content.opacity(1).scaleEffect(1).offset(y: 0).blur(radius: 0)
            }

            let zone: CGFloat = 150
            let fromBottom = min(1.0, max(0.0, (viewportHeight - frame.minY) / zone))
            let fromTop = min(1.0, max(0.0, frame.maxY / zone))
            let rawProgress = min(fromBottom, fromTop)

            // Smoothstep easing for natural deceleration
            let progress = rawProgress * rawProgress * (3 - 2 * rawProgress)

            // Direction: -1 near top edge, +1 near bottom edge
            let direction: CGFloat = fromTop < fromBottom ? -1 : 1

            return content
                .opacity(0.35 + 0.65 * progress)
                .scaleEffect(0.92 + 0.08 * progress)
                .offset(y: direction * 8 * (1 - progress))
                .blur(radius: (1 - progress) * 3)
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
