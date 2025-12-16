//
//  MarkdownRenderer.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation
import SwiftUI

/// Renders Markdown content to AttributedString with styling
@available(iOS 18.0, *)
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
            } else if line.starts(with: ":::postscript") {
                // Postscript/appendix block (V2EX div.subtle)
                let postscriptBlock = extractPostscriptBlock(lines, startIndex: index)
                attributedString.append(renderPostscript(postscriptBlock))
                index += postscriptBlock.2
                continue
            } else if line.trimmingCharacters(in: .whitespaces).starts(with: ">") {
                // Blockquote - handle "> ", ">", ">> ", etc.
                var content = line.trimmingCharacters(in: .whitespaces)
                var depth = 0
                // Strip leading > characters and spaces
                while content.starts(with: ">") {
                    content = String(content.dropFirst())
                    depth += 1
                    // Remove space after >
                    if content.starts(with: " ") {
                        content = String(content.dropFirst())
                    }
                }
                content = content.trimmingCharacters(in: .whitespaces)
                // Only render if there's actual content or if it's a continuation
                if !content.isEmpty {
                    attributedString.append(renderBlockquote(content, depth: depth))
                }
            } else if line.starts(with: "- ") || line.starts(with: "* ") {
                // Unordered list
                let content = String(line.dropFirst(2))
                attributedString.append(renderListItem(content, ordered: false, number: 0))
            } else if let (number, content) = extractOrderedListItem(from: line) {
                // Ordered list
                attributedString.append(renderListItem(content, ordered: true, number: number))
            } else if line.starts(with: "---") {
                // Horizontal rule
                attributedString.append(renderHorizontalRule())
            } else if line.starts(with: "|") && line.hasSuffix("|") {
                // Markdown table
                let (tableBlock, linesConsumed) = extractTableBlock(lines, startIndex: index)
                attributedString.append(renderTable(tableBlock))
                index += linesConsumed
                continue
            } else {
                // Regular paragraph with inline formatting
                attributedString.append(renderInlineMarkdown(line))
                // Only add newline if there are more lines to process
                if index < lines.count - 1 {
                    attributedString.append(AttributedString("\n"))
                }
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

    private func renderBlockquote(_ text: String, depth: Int = 1) -> AttributedString {
        var result = AttributedString()

        // Add visual indent/border indicator based on depth
        let indent = String(repeating: "┃ ", count: depth)
        var indentAttr = AttributedString(indent)
        indentAttr.foregroundColor = stylesheet.blockquote.borderColor.uiColor

        result.append(indentAttr)

        // Render the content
        if text.isEmpty {
            // Empty blockquote line - just show the border
            result.append(AttributedString("\n"))
        } else {
            var contentAttr = renderInlineMarkdown(text)
            contentAttr.font = .system(size: stylesheet.blockquote.fontSize)
            contentAttr.foregroundColor = stylesheet.body.color.uiColor
            result.append(contentAttr)
            result.append(AttributedString("\n"))
        }

        return result
    }

    // MARK: - Horizontal Rule Rendering

    private func renderHorizontalRule() -> AttributedString {
        // Use Unicode box drawing light horizontal line (U+2500)
        // Single line with proper spacing
        var line = AttributedString("────────────────────────────────────────────────────────────────────────────────")
        line.foregroundColor = stylesheet.horizontalRule.color.uiColor
        var result = AttributedString("\n")
        result.append(line)
        result.append(AttributedString("\n"))
        return result
    }

    // MARK: - List Rendering

    private func renderListItem(_ text: String, ordered: Bool, number: Int) -> AttributedString {
        // Check for task list item (checkbox)
        if let (isChecked, content) = extractCheckbox(from: text) {
            return renderCheckboxItem(content: content, isChecked: isChecked)
        }

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

    /// Extract checkbox state from task list item
    private func extractCheckbox(from text: String) -> (isChecked: Bool, content: String)? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // Check for [x] or [X] (checked) - with or without trailing space
        if trimmed.hasPrefix("[x] ") || trimmed.hasPrefix("[X] ") {
            return (true, String(trimmed.dropFirst(4)))
        }
        if trimmed == "[x]" || trimmed == "[X]" {
            return (true, "")
        }

        // Check for [ ] (unchecked) - with or without trailing space
        if trimmed.hasPrefix("[ ] ") {
            return (false, String(trimmed.dropFirst(4)))
        }
        if trimmed == "[ ]" {
            return (false, "")
        }

        return nil
    }

    /// Render a checkbox item with visual indicator
    private func renderCheckboxItem(content: String, isChecked: Bool) -> AttributedString {
        var result = AttributedString()

        // Use SF Symbol-like Unicode characters for checkbox appearance
        // ✓ with circle for checked, ○ for unchecked
        let checkboxSymbol = isChecked ? "✓ " : "○ "
        var checkboxAttr = AttributedString(checkboxSymbol)

        checkboxAttr.foregroundColor = (isChecked ? stylesheet.list.checkboxCheckedColor : stylesheet.list.checkboxUncheckedColor).uiColor

        result.append(checkboxAttr)
        result.append(renderInlineMarkdown(content))
        result.append(AttributedString("\n"))

        return result
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

            // Check for strikethrough
            if let strikeMatch = currentText.firstMatch(of: /~~(.+?)~~/) {
                // Add text before strikethrough
                let beforeRange = currentText.startIndex..<strikeMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add strikethrough text
                var strikeText = AttributedString(String(strikeMatch.1))
                strikeText.font = .system(size: stylesheet.body.fontSize)
                strikeText.foregroundColor = stylesheet.body.color.uiColor
                strikeText.strikethroughStyle = .single
                result.append(strikeText)

                // Continue with remaining text
                currentText = String(currentText[strikeMatch.range.upperBound...])
                continue
            }

            // Check for highlight/mark
            if let highlightMatch = currentText.firstMatch(of: /==(.+?)==/) {
                // Add text before highlight
                let beforeRange = currentText.startIndex..<highlightMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add highlighted text
                var highlightText = AttributedString(String(highlightMatch.1))
                highlightText.font = .system(size: stylesheet.body.fontSize)
                highlightText.foregroundColor = stylesheet.body.color.uiColor
                highlightText.backgroundColor = Color.yellow.opacity(0.3)
                result.append(highlightText)

                // Continue with remaining text
                currentText = String(currentText[highlightMatch.range.upperBound...])
                continue
            }

            // Check for underline (<u>text</u>)
            if let underlineMatch = currentText.firstMatch(of: /<u>(.+?)<\/u>/) {
                // Add text before underline
                let beforeRange = currentText.startIndex..<underlineMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add underlined text
                var underlineText = AttributedString(String(underlineMatch.1))
                underlineText.font = .system(size: stylesheet.body.fontSize)
                underlineText.foregroundColor = stylesheet.body.color.uiColor
                underlineText.underlineStyle = .single
                result.append(underlineText)

                // Continue with remaining text
                currentText = String(currentText[underlineMatch.range.upperBound...])
                continue
            }

            // Check for superscript (<sup>text</sup>)
            if let supMatch = currentText.firstMatch(of: /<sup>(.+?)<\/sup>/) {
                // Add text before superscript
                let beforeRange = currentText.startIndex..<supMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add superscript text (smaller font, baseline offset)
                var supText = AttributedString(String(supMatch.1))
                supText.font = .system(size: stylesheet.body.fontSize * 0.7)
                supText.foregroundColor = stylesheet.body.color.uiColor
                supText.baselineOffset = stylesheet.body.fontSize * 0.3
                result.append(supText)

                // Continue with remaining text
                currentText = String(currentText[supMatch.range.upperBound...])
                continue
            }

            // Check for subscript (<sub>text</sub>)
            if let subMatch = currentText.firstMatch(of: /<sub>(.+?)<\/sub>/) {
                // Add text before subscript
                let beforeRange = currentText.startIndex..<subMatch.range.lowerBound
                if !beforeRange.isEmpty {
                    result.append(renderPlainText(String(currentText[beforeRange])))
                }

                // Add subscript text (smaller font, negative baseline offset)
                var subText = AttributedString(String(subMatch.1))
                subText.font = .system(size: stylesheet.body.fontSize * 0.7)
                subText.foregroundColor = stylesheet.body.color.uiColor
                subText.baselineOffset = -stylesheet.body.fontSize * 0.2
                result.append(subText)

                // Continue with remaining text
                currentText = String(currentText[subMatch.range.upperBound...])
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

    // MARK: - Table Rendering

    /// Extract table block from lines
    private func extractTableBlock(_ lines: [String], startIndex: Int) -> ([[String]], Int) {
        var rows: [[String]] = []
        var index = startIndex

        while index < lines.count {
            let line = lines[index]

            // Check if line is a table row
            guard line.starts(with: "|") && line.hasSuffix("|") else {
                break
            }

            // Skip separator row (| --- | --- | or with colons for alignment)
            if line.range(of: #"^\|\s*(:?-+:?)\s*(\|\s*(:?-+:?)\s*)*\|$"#, options: .regularExpression) != nil {
                index += 1
                continue
            }

            // Parse cells
            let cells = line
                .trimmingCharacters(in: CharacterSet(charactersIn: "|"))
                .components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            if !cells.isEmpty {
                rows.append(cells)
            }

            index += 1
        }

        return (rows, index - startIndex)
    }

    /// Render markdown table
    private func renderTable(_ rows: [[String]]) -> AttributedString {
        guard !rows.isEmpty else { return AttributedString() }

        var result = AttributedString("\n")

        // Get column count
        let columnCount = rows.map { $0.count }.max() ?? 0
        guard columnCount > 0 else { return AttributedString() }

        // Calculate column widths for alignment
        var columnWidths: [Int] = Array(repeating: 0, count: columnCount)
        for row in rows {
            for (i, cell) in row.enumerated() where i < columnCount {
                columnWidths[i] = max(columnWidths[i], cell.count)
            }
        }

        for (rowIndex, row) in rows.enumerated() {
            // Render each cell
            for (cellIndex, cell) in row.enumerated() {
                // Add cell content
                var cellText = renderInlineMarkdown(cell)

                // Apply header style for first row
                if rowIndex == 0 {
                    cellText.font = .system(size: stylesheet.body.fontSize, weight: stylesheet.table.headerFontWeight)
                }

                result.append(cellText)

                // Add separator between cells
                if cellIndex < row.count - 1 {
                    var separator = AttributedString("  │  ")
                    separator.foregroundColor = stylesheet.table.separatorColor.uiColor
                    result.append(separator)
                }
            }

            result.append(AttributedString("\n"))

            // Add separator line after header
            if rowIndex == 0 && rows.count > 1 {
                var separatorLine = AttributedString(String(repeating: "─", count: 40) + "\n")
                separatorLine.foregroundColor = stylesheet.table.separatorColor.uiColor
                result.append(separatorLine)
            }
        }

        result.append(AttributedString("\n"))
        return result
    }

    // MARK: - Postscript/Appendix Rendering

    /// Extract postscript block from lines
    private func extractPostscriptBlock(_ lines: [String], startIndex: Int) -> (header: String?, content: String, Int) {
        var header: String? = nil
        var content = ""
        var index = startIndex + 1

        while index < lines.count {
            let line = lines[index]

            if line.starts(with: ":::/postscript") {
                return (header, content, index - startIndex + 1)
            }

            // Check for header line
            if line.starts(with: "::header::") {
                header = String(line.dropFirst("::header::".count))
                index += 1
                continue
            }

            content += line + "\n"
            index += 1
        }

        return (header, content, index - startIndex)
    }

    /// Render postscript/appendix block with gold left border
    private func renderPostscript(_ block: (header: String?, content: String, Int)) -> AttributedString {
        var result = AttributedString()

        // Add some vertical spacing before the postscript
        result.append(AttributedString("\n"))

        // Render header if present
        if let header = block.header, !header.isEmpty {
            // Add visual border indicator
            var borderAttr = AttributedString("┃ ")
            borderAttr.foregroundColor = stylesheet.postscript.borderColor.uiColor

            result.append(borderAttr)

            var headerAttr = AttributedString(header)
            headerAttr.font = .system(size: stylesheet.postscript.headerFontSize)
            headerAttr.foregroundColor = stylesheet.postscript.headerColor.uiColor
            result.append(headerAttr)
            result.append(AttributedString("\n"))
        }

        // Render content with border
        let contentLines = block.content.split(separator: "\n", omittingEmptySubsequences: false)
        for line in contentLines {
            // Add visual border indicator
            var borderAttr = AttributedString("┃ ")
            borderAttr.foregroundColor = stylesheet.postscript.borderColor.uiColor
            result.append(borderAttr)

            // Render inline content
            if line.isEmpty {
                result.append(AttributedString("\n"))
            } else {
                var contentAttr = renderInlineMarkdown(String(line))
                contentAttr.font = .system(size: stylesheet.postscript.contentFontSize)
                result.append(contentAttr)
                result.append(AttributedString("\n"))
            }
        }

        // Add vertical spacing after the postscript
        result.append(AttributedString("\n"))

        return result
    }
}
