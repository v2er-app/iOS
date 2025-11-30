//
//  RenderStylesheet.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

/// Complete stylesheet for RichView rendering
public struct RenderStylesheet: Equatable {
    public var body: TextStyle
    public var heading: HeadingStyle
    public var link: LinkStyle
    public var code: CodeStyle
    public var blockquote: BlockquoteStyle
    public var list: ListStyle
    public var mention: MentionStyle
    public var image: ImageStyle

    public init(
        body: TextStyle = TextStyle(),
        heading: HeadingStyle = HeadingStyle(),
        link: LinkStyle = LinkStyle(),
        code: CodeStyle = CodeStyle(),
        blockquote: BlockquoteStyle = BlockquoteStyle(),
        list: ListStyle = ListStyle(),
        mention: MentionStyle = MentionStyle(),
        image: ImageStyle = ImageStyle()
    ) {
        self.body = body
        self.heading = heading
        self.link = link
        self.code = code
        self.blockquote = blockquote
        self.list = list
        self.mention = mention
        self.image = image
    }
}

// MARK: - Style Components

/// Body text styling
public struct TextStyle: Equatable {
    public var fontSize: CGFloat
    public var fontWeight: Font.Weight
    public var lineSpacing: CGFloat
    public var paragraphSpacing: CGFloat
    public var color: Color

    public init(
        fontSize: CGFloat = 17,
        fontWeight: Font.Weight = .regular,
        lineSpacing: CGFloat = 5,
        paragraphSpacing: CGFloat = 10,
        color: Color = .primary
    ) {
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
        self.color = color
    }
}

/// Heading styles for h1-h6
public struct HeadingStyle: Equatable {
    public var h1Size: CGFloat
    public var h2Size: CGFloat
    public var h3Size: CGFloat
    public var h4Size: CGFloat
    public var h5Size: CGFloat
    public var h6Size: CGFloat
    public var fontWeight: Font.Weight
    public var topSpacing: CGFloat
    public var bottomSpacing: CGFloat
    public var color: Color

    public init(
        h1Size: CGFloat = 32,
        h2Size: CGFloat = 28,
        h3Size: CGFloat = 24,
        h4Size: CGFloat = 20,
        h5Size: CGFloat = 18,
        h6Size: CGFloat = 16,
        fontWeight: Font.Weight = .bold,
        topSpacing: CGFloat = 16,
        bottomSpacing: CGFloat = 8,
        color: Color = .primary
    ) {
        self.h1Size = h1Size
        self.h2Size = h2Size
        self.h3Size = h3Size
        self.h4Size = h4Size
        self.h5Size = h5Size
        self.h6Size = h6Size
        self.fontWeight = fontWeight
        self.topSpacing = topSpacing
        self.bottomSpacing = bottomSpacing
        self.color = color
    }
}

/// Link styling
public struct LinkStyle: Equatable {
    public var color: Color
    public var underline: Bool
    public var fontWeight: Font.Weight

    public init(
        color: Color = .blue,
        underline: Bool = false,
        fontWeight: Font.Weight = .regular
    ) {
        self.color = color
        self.underline = underline
        self.fontWeight = fontWeight
    }
}

/// Code and code block styling
public struct CodeStyle: Equatable {
    public var inlineFontSize: CGFloat
    public var inlineBackgroundColor: Color
    public var inlineTextColor: Color
    public var inlinePadding: EdgeInsets

    public var blockFontSize: CGFloat
    public var blockBackgroundColor: Color
    public var blockTextColor: Color
    public var blockPadding: EdgeInsets
    public var blockCornerRadius: CGFloat

    public var fontName: String
    public var highlightTheme: HighlightTheme

    public init(
        inlineFontSize: CGFloat = 14,
        inlineBackgroundColor: Color = Color(hex: "#f6f8fa"),
        inlineTextColor: Color = Color(hex: "#24292e"),
        inlinePadding: EdgeInsets = EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4),
        blockFontSize: CGFloat = 14,
        blockBackgroundColor: Color = Color(hex: "#f6f8fa"),
        blockTextColor: Color = Color(hex: "#24292e"),
        blockPadding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        blockCornerRadius: CGFloat = 6,
        fontName: String = "Menlo",
        highlightTheme: HighlightTheme = .github
    ) {
        self.inlineFontSize = inlineFontSize
        self.inlineBackgroundColor = inlineBackgroundColor
        self.inlineTextColor = inlineTextColor
        self.inlinePadding = inlinePadding
        self.blockFontSize = blockFontSize
        self.blockBackgroundColor = blockBackgroundColor
        self.blockTextColor = blockTextColor
        self.blockPadding = blockPadding
        self.blockCornerRadius = blockCornerRadius
        self.fontName = fontName
        self.highlightTheme = highlightTheme
    }

    public enum HighlightTheme: String, CaseIterable {
        case github
        case githubDark = "github-dark"
        case monokai
        case xcode
        case vs2015
        case atomOneDark = "atom-one-dark"
        case solarizedLight = "solarized-light"
        case solarizedDark = "solarized-dark"
        case tomorrowNight = "tomorrow-night"
    }
}

/// Blockquote styling
public struct BlockquoteStyle: Equatable {
    public var borderColor: Color
    public var borderWidth: CGFloat
    public var backgroundColor: Color
    public var padding: EdgeInsets
    public var fontSize: CGFloat

    public init(
        borderColor: Color = Color(hex: "#d0d7de"),
        borderWidth: CGFloat = 4,
        backgroundColor: Color = Color(hex: "#f6f8fa").opacity(0.5),
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8),
        fontSize: CGFloat = 15
    ) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.fontSize = fontSize
    }
}

/// List styling
public struct ListStyle: Equatable {
    public var indentWidth: CGFloat
    public var itemSpacing: CGFloat
    public var bulletColor: Color
    public var numberColor: Color

    public init(
        indentWidth: CGFloat = 20,
        itemSpacing: CGFloat = 4,
        bulletColor: Color = .primary,
        numberColor: Color = .primary
    ) {
        self.indentWidth = indentWidth
        self.itemSpacing = itemSpacing
        self.bulletColor = bulletColor
        self.numberColor = numberColor
    }
}

/// @mention styling
public struct MentionStyle: Equatable {
    public var textColor: Color
    public var backgroundColor: Color
    public var fontWeight: Font.Weight

    public init(
        textColor: Color = .blue,
        backgroundColor: Color = .blue.opacity(0.1),
        fontWeight: Font.Weight = .medium
    ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.fontWeight = fontWeight
    }
}

/// Image styling
public struct ImageStyle: Equatable {
    public var maxWidth: CGFloat
    public var maxHeight: CGFloat
    public var cornerRadius: CGFloat
    public var borderColor: Color
    public var borderWidth: CGFloat

    public init(
        maxWidth: CGFloat = .infinity,
        maxHeight: CGFloat = 400,
        cornerRadius: CGFloat = 8,
        borderColor: Color = Color(hex: "#d0d7de"),
        borderWidth: CGFloat = 1
    ) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

// MARK: - Presets

extension RenderStylesheet {
    /// GitHub Markdown default styling (adaptive for dark mode)
    public static let `default`: RenderStylesheet = {
        RenderStylesheet(
            body: TextStyle(
                fontSize: 17,
                fontWeight: .regular,
                lineSpacing: 5,
                paragraphSpacing: 10,
                color: .primary
            ),
            heading: HeadingStyle(
                h1Size: 32,
                h2Size: 28,
                h3Size: 24,
                h4Size: 20,
                h5Size: 18,
                h6Size: 16,
                fontWeight: .bold,
                topSpacing: 16,
                bottomSpacing: 8,
                color: .primary
            ),
            link: LinkStyle(
                color: Color.adaptive(
                    light: Color(hex: "#0969da"),
                    dark: Color(hex: "#58a6ff")
                ),
                underline: false,
                fontWeight: .regular
            ),
            code: CodeStyle(
                inlineBackgroundColor: Color.adaptive(
                    light: Color(hex: "#f6f8fa"),
                    dark: Color(hex: "#161b22")
                ),
                inlineTextColor: Color.adaptive(
                    light: Color(hex: "#24292e"),
                    dark: Color(hex: "#e6edf3")
                ),
                blockBackgroundColor: Color.adaptive(
                    light: Color(hex: "#f6f8fa"),
                    dark: Color(hex: "#161b22")
                ),
                blockTextColor: Color.adaptive(
                    light: Color(hex: "#24292e"),
                    dark: Color(hex: "#e6edf3")
                ),
                highlightTheme: .github
            ),
            blockquote: BlockquoteStyle(
                borderColor: Color.adaptive(
                    light: Color(hex: "#d0d7de"),
                    dark: Color(hex: "#3d444d")
                ),
                backgroundColor: Color.adaptive(
                    light: Color(hex: "#f6f8fa").opacity(0.5),
                    dark: Color(hex: "#161b22").opacity(0.5)
                )
            ),
            list: ListStyle(),
            mention: MentionStyle(
                textColor: Color.adaptive(
                    light: Color(hex: "#0969da"),
                    dark: Color(hex: "#58a6ff")
                ),
                backgroundColor: Color.adaptive(
                    light: Color.blue.opacity(0.1),
                    dark: Color.blue.opacity(0.2)
                )
            ),
            image: ImageStyle(
                borderColor: Color.adaptive(
                    light: Color(hex: "#d0d7de"),
                    dark: Color(hex: "#3d444d")
                )
            )
        )
    }()

    /// Compact styling for replies
    public static let compact: RenderStylesheet = {
        RenderStylesheet(
            body: TextStyle(
                fontSize: 15,
                fontWeight: .regular,
                lineSpacing: 4,
                paragraphSpacing: 8,
                color: .primary
            ),
            heading: HeadingStyle(
                h1Size: 24,
                h2Size: 20,
                h3Size: 18,
                h4Size: 16,
                h5Size: 15,
                h6Size: 14,
                fontWeight: .semibold,
                topSpacing: 8,
                bottomSpacing: 4,
                color: .primary
            ),
            link: LinkStyle(
                color: Color(hex: "#0969da"),
                underline: false,
                fontWeight: .regular
            ),
            code: CodeStyle(
                inlineFontSize: 12,
                blockFontSize: 12,
                highlightTheme: .github
            ),
            blockquote: BlockquoteStyle(
                fontSize: 13
            ),
            list: ListStyle(
                indentWidth: 16,
                itemSpacing: 2
            ),
            mention: MentionStyle(),
            image: ImageStyle(
                maxHeight: 300
            )
        )
    }()

    /// High contrast accessibility styling
    public static let accessibility: RenderStylesheet = {
        RenderStylesheet(
            body: TextStyle(
                fontSize: 18,
                fontWeight: .regular,
                lineSpacing: 6,
                paragraphSpacing: 12,
                color: .primary
            ),
            heading: HeadingStyle(
                h1Size: 36,
                h2Size: 32,
                h3Size: 28,
                h4Size: 24,
                h5Size: 20,
                h6Size: 18,
                fontWeight: .bold,
                topSpacing: 20,
                bottomSpacing: 10,
                color: .primary
            ),
            link: LinkStyle(
                color: .blue,
                underline: true,
                fontWeight: .medium
            ),
            code: CodeStyle(
                inlineFontSize: 16,
                blockFontSize: 16,
                highlightTheme: .xcode
            ),
            blockquote: BlockquoteStyle(
                borderWidth: 6,
                fontSize: 17
            ),
            list: ListStyle(
                indentWidth: 24,
                itemSpacing: 6
            ),
            mention: MentionStyle(
                fontWeight: .bold
            ),
            image: ImageStyle()
        )
    }()
}

// MARK: - Color Extension

extension Color {
    /// Initialize Color from hex string
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Create adaptive color for light/dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}