//
//  Typography.swift
//  V2er
//
//  Design token: named font styles mapping to Dynamic Type.
//  Every style uses a semantic TextStyle, ensuring proper scaling
//  with the user's preferred content size.
//

import SwiftUI

enum AppFont {
    /// Brand title in navigation bar — monospaced for stable width during V2EX ↔ V2er animation
    static let brandTitle: Font = .system(.title2, design: .monospaced).weight(.black)

    /// Section headers — replaces inline .headline.weight(.heavy)
    static let sectionTitle: Font = .headline.weight(.heavy)

    /// Small section headers — replaces inline .subheadline.weight(.heavy)
    static let sectionTitleSmall: Font = .subheadline.weight(.heavy)

    /// Owner badge label — replaces .system(size: 8)
    static let ownerBadge: Font = .caption2

    /// Heart / action icons — replaces .system(size: 14)
    static let actionIcon: Font = .subheadline

    /// Reply count, metadata — replaces inline .footnote
    static let metadata: Font = .footnote

    /// User name in feed items — replaces inline .footnote
    static let username: Font = .footnote

    /// Timestamp, secondary info — replaces inline .caption2
    static let timestamp: Font = .caption2

    /// Body text — replaces .system(size: 17) and similar
    static let bodyText: Font = .body

    /// Semibold body — replaces .system(size: 17).weight(.semibold)
    static let bodySemibold: Font = .body.weight(.semibold)

    /// Navigation filter label — replaces inline .headline.weight(.bold)
    static let filterLabel: Font = .headline.weight(.bold)

    /// Filter chevron — replaces .system(size: 12, weight: .semibold)
    static let filterChevron: Font = .caption.weight(.semibold)
}
