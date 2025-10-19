//
//  MarkdownRenderer.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation
import SwiftUI

/// Renders Markdown content to AttributedString with styling
@available(iOS 16.0, *)
public class MarkdownRenderer {

    private let stylesheet: RenderStylesheet
    private let enableCodeHighlighting: Bool

    /// Initialize renderer with configuration
    public init(stylesheet: RenderStylesheet, enableCodeHighlighting: Bool = true) {
        self.stylesheet = stylesheet
        self.enableCodeHighlighting = enableCodeHighlighting
    }

    /// Render Markdown string to AttributedString
    public func render(_ markdown: String) throws -> AttributedString {
        var attributedString = AttributedString()

        // Split into lines for processing
        let lines = markdown.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            let line = lines[index]

            // Skip empty lines
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !attributedString.characters.isEmpty {
                    attributedString.append(AttributedString("\n"))
                }
                index += 1
                continue
            }

            // Process different Markdown elements
            if line.starts(with: "# ") {
                let content = String(line.dropFirst(2))
                attributedString.append(renderHeading(content, level: 1))
            } else if line.starts(with: "## ") {
                let content = String(line.dropFirst(3))
                attributedString.append(renderHeading(content, level: 2))
            } else if line.starts(with: "### ") {
                let content = String(line.dropFirst(4))
                attributedString.append(renderHeading(content, level: 3))
            } else if line.starts(with: "#### ") {
                let content = String(line.dropFirst(5))
                attributedString.append(renderHeading(content, level: 4))
            } else if line.starts(with: "##### ") {
                let content = String(line.dropFirst(6))
                attributedString.append(renderHeading(content, level: 5))
            } else if line.starts(with: "###### ") {
                let content = String(line.dropFirst(7))
                attributedString.append(renderHeading(content, level: 6))
            } else if line.starts(with: "```") {
                // Code block
                let (codeBlock, linesConsumed) = extractCodeBlock(lines, startIndex: index)
                attributedString.append(renderCodeBlock(codeBlock))
                index += linesConsumed
                continue
            } else if line.starts(with: "> ") {
                // Blockquote
                let content = String(line.dropFirst(2))
                attributedString.append(renderBlockquote(content))
            } else if line.starts(with: "- ") || line.starts(with: "* ") {
                // Unordered list
                let content = String(line.dropFirst(2))
                attributedString.append(renderListItem(content, ordered: false, number: 0))
            } else if let (number, content) = extractOrderedListItem(from: line) {
                // Ordered list
                attributedString.append(renderListItem(content, ordered: true, number: number))
            } else if line.starts(with: "---") {
                // Horizontal rule
                attributedString.append(AttributedString("—————————————\n"))
            } else {
                // Regular paragraph with inline formatting
                attributedString.append(renderInlineMarkdown(line))
                attributedString.append(AttributedString("\n"))
            }

            index += 1
        }

        return attributedString
    }

    // MARK: - Heading Rendering

    private func renderHeading(_ text: String, level: Int) -> AttributedString {
        var attributed = renderInlineMarkdown(text)

        // Apply heading style
        let fontSize: CGFloat
        switch level {
        case 1: fontSize = stylesheet.heading.h1Size
        case 2: fontSize = stylesheet.heading.h2Size
        case 3: fontSize = stylesheet.heading.h3Size
        case 4: fontSize = stylesheet.heading.h4Size
        case 5: fontSize = stylesheet.heading.h5Size
        case 6: fontSize = stylesheet.heading.h6Size
        default: fontSize = stylesheet.heading.h1Size
        }

        attributed.font = .system(size: fontSize, weight: stylesheet.heading.fontWeight)
        attributed.foregroundColor = stylesheet.heading.color.uiColor

        // Add spacing
        attributed.append(AttributedString("\n\n"))

        return attributed
    }

    // MARK: - Code Block Rendering

    private func extractCodeBlock(_ lines: [String], startIndex: Int) -> (String, Int) {
        var code = ""
        var index = startIndex + 1

        while index < lines.count {
            if lines[index].starts(with: "```") {
                return (code, index - startIndex + 1)
            }
            code += lines[index] + "\n"
            index += 1
        }

        return (code, index - startIndex)
    }

    private func renderCodeBlock(_ code: String) -> AttributedString {
        var attributed = AttributedString(code)

        // Apply code block styling
        attributed.font = .system(size: stylesheet.code.blockFontSize).monospaced()
        attributed.foregroundColor = stylesheet.code.blockTextColor.uiColor
        attributed.backgroundColor = stylesheet.code.blockBackgroundColor.uiColor

        attributed.append(AttributedString("\n"))

        return attributed
    }

    // MARK: - Blockquote Rendering

    private func renderBlockquote(_ text: String) -> AttributedString {
        var attributed = renderInlineMarkdown(text)

        // Apply blockquote styling
        attributed.font = .system(size: stylesheet.blockquote.fontSize)
        attributed.foregroundColor = stylesheet.blockquote.borderColor.uiColor
        attributed.backgroundColor = stylesheet.blockquote.backgroundColor.uiColor

        attributed.append(AttributedString("\n"))

        return attributed
    }

    // MARK: - List Rendering

    private func renderListItem(_ text: String, ordered: Bool, number: Int) -> AttributedString {
        let bullet = ordered ? "\(number). " : "• "
        var attributed = AttributedString(bullet)

        if ordered {
            attributed.foregroundColor = stylesheet.list.numberColor.uiColor
        } else {
            attributed.foregroundColor = stylesheet.list.bulletColor.uiColor
        }

        attributed.append(renderInlineMarkdown(text))
        attributed.append(AttributedString("\n"))

        return attributed
    }

    // MARK: - Inline Markdown Rendering

    private func renderInlineMarkdown(_ text: String) -> AttributedString {
        var result = AttributedString()
        var currentText = text

        // Process inline elements
        while !currentText.isEmpty {
            // Check for bold
            if let boldMatch = currentText.firstMatch(of: /\*\*(.+?)\*\*/) {
                // Add text before bold
                let beforeRange = currentText.startIndex..<boldMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add bold text
                var boldText = AttributedString(String(boldMatch.1))
                boldText.font = .system(size: stylesheet.body.fontSize, weight: .bold)
                boldText.foregroundColor = stylesheet.body.color.uiColor
                result.append(boldText)

                // Continue with remaining text
                currentText = String(currentText[boldMatch.range.upperBound...])
                continue
            }

            // Check for italic
            if let italicMatch = currentText.firstMatch(of: /\*(.+?)\*/) {
                // Add text before italic
                let beforeRange = currentText.startIndex..<italicMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add italic text
                var italicText = AttributedString(String(italicMatch.1))
                italicText.font = .system(size: stylesheet.body.fontSize).italic()
                italicText.foregroundColor = stylesheet.body.color.uiColor
                result.append(italicText)

                // Continue with remaining text
                currentText = String(currentText[italicMatch.range.upperBound...])
                continue
            }

            // Check for inline code
            if let codeMatch = currentText.firstMatch(of: /`(.+?)`/) {
                // Add text before code
                let beforeRange = currentText.startIndex..<codeMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add code text
                var codeText = AttributedString(String(codeMatch.1))
                codeText.font = .system(size: stylesheet.code.inlineFontSize).monospaced()
                codeText.foregroundColor = stylesheet.code.inlineTextColor.uiColor
                codeText.backgroundColor = stylesheet.code.inlineBackgroundColor.uiColor
                result.append(codeText)

                // Continue with remaining text
                currentText = String(currentText[codeMatch.range.upperBound...])
                continue
            }

            // Check for links
            if let linkMatch = currentText.firstMatch(of: /\[(.+?)\]\((.+?)\)/) {
                // Add text before link
                let beforeRange = currentText.startIndex..<linkMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add link text
                let linkText = String(linkMatch.1)
                let linkURL = String(linkMatch.2)
                var linkAttributed = AttributedString(linkText)
                linkAttributed.font = .system(size: stylesheet.body.fontSize, weight: stylesheet.link.fontWeight)
                linkAttributed.foregroundColor = stylesheet.link.color.uiColor
                if stylesheet.link.underline {
                    linkAttributed.underlineStyle = .single
                    linkAttributed.underlineColor = stylesheet.link.color.uiColor
                }
                if let url = URL(string: linkURL) {
                    linkAttributed.link = url
                }
                result.append(linkAttributed)

                // Continue with remaining text
                currentText = String(currentText[linkMatch.range.upperBound...])
                continue
            }

            // Check for @mention
            if let mentionMatch = currentText.firstMatch(of: /@([a-zA-Z0-9_]+)/) {
                // Add text before mention
                let beforeRange = currentText.startIndex..<mentionMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add mention
                let username = String(mentionMatch.1)
                var mentionText = AttributedString("@\(username)")
                mentionText.font = .system(size: stylesheet.body.fontSize, weight: stylesheet.mention.fontWeight)
                mentionText.foregroundColor = stylesheet.mention.textColor.uiColor
                mentionText.backgroundColor = stylesheet.mention.backgroundColor.uiColor
                result.append(mentionText)

                // Continue with remaining text
                currentText = String(currentText[mentionMatch.range.upperBound...])
                continue
            }

            // No more special elements, add remaining text
            result.append(renderPlainText(currentText))
            break
        }

        return result
    }

    private func renderPlainText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        attributed.font = .system(size: stylesheet.body.fontSize, weight: stylesheet.body.fontWeight)
        attributed.foregroundColor = stylesheet.body.color.uiColor
        return attributed
    }

    // MARK: - Helper Methods

    /// Extract ordered list item number and content from a line
    private func extractOrderedListItem(from line: String) -> (Int, String)? {
        guard let match = line.firstMatch(of: /^(\d+)\. (.+)/) else {
            return nil
        }
        let number = Int(match.1) ?? 1
        let content = String(match.2)
        return (number, content)
    }
}
