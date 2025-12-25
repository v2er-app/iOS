//
//  HTMLToMarkdownConverter.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation
import SwiftSoup

/// Converts HTML content to Markdown format
public class HTMLToMarkdownConverter {

    /// Configuration for crash behavior
    private let crashOnUnsupportedTags: Bool

    /// Initialize converter
    public init(crashOnUnsupportedTags: Bool = true) {
        self.crashOnUnsupportedTags = crashOnUnsupportedTags
    }

    /// Convert HTML string to Markdown
    public func convert(_ html: String) throws -> String {
        // Pre-process V2EX specific URLs
        let preprocessedHTML = preprocessV2EXContent(html)

        // Parse HTML
        let doc = try SwiftSoup.parse(preprocessedHTML)
        let body = doc.body() ?? doc

        // Convert to Markdown
        let markdown = try convertElement(body)

        // Clean up extra whitespace
        return cleanupMarkdown(markdown)
    }

    /// Pre-process V2EX specific content
    private func preprocessV2EXContent(_ html: String) -> String {
        var processed = html

        // Fix V2EX URLs that start with //
        processed = processed.replacingOccurrences(
            of: "href=\"//",
            with: "href=\"https://"
        )
        processed = processed.replacingOccurrences(
            of: "src=\"//",
            with: "src=\"https://"
        )

        // Fix relative URLs
        processed = processed.replacingOccurrences(
            of: "href=\"/",
            with: "href=\"https://www.v2ex.com/"
        )

        return processed
    }

    /// Convert HTML element to Markdown recursively
    private func convertElement(_ element: Element) throws -> String {
        var result = ""

        for node in element.getChildNodes() {
            if let textNode = node as? TextNode {
                // Plain text
                result += escapeMarkdown(textNode.text())
            } else if let childElement = node as? Element {
                // Process element based on tag
                let tagName = childElement.tagName().lowercased()

                switch tagName {
                // Basic text formatting
                case "p":
                    let content = try convertElement(childElement)
                    // Only add paragraph if it has actual content (skip empty <p> tags)
                    if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        result += "\n\n\(content)\n\n"
                    }

                case "br":
                    result += "  \n"

                case "strong", "b":
                    let content = try convertElement(childElement)
                    result += "**\(content)**"

                case "em", "i":
                    let content = try convertElement(childElement)
                    result += "*\(content)*"

                case "a":
                    // Check if this link wraps an image (common V2EX pattern)
                    if let img = try? childElement.select("img").first(),
                       let src = try? img.attr("src"), !src.isEmpty {
                        // Link wrapping an image - output as markdown image
                        // The image will be clickable via onImageTapped handler
                        let alt = (try? img.attr("alt")) ?? "image"
                        result += "![\(alt)](\(src))"
                    } else {
                        // Regular link with text
                        let text = try childElement.text()
                        if let href = try? childElement.attr("href") {
                            result += "[\(text)](\(href))"
                        } else {
                            result += text
                        }
                    }

                case "code":
                    // Check if this is inside a pre tag (handled separately)
                    if childElement.parent()?.tagName().lowercased() == "pre" {
                        result += try childElement.text()
                    } else {
                        // Inline code
                        let content = try childElement.text()
                        result += "`\(content)`"
                    }

                case "pre":
                    // Code block
                    let content = try childElement.text()
                    let language = try? childElement.attr("class")
                        .split(separator: " ")
                        .first(where: { $0.hasPrefix("language-") })
                        .map { String($0.dropFirst("language-".count)) }

                    if let lang = language {
                        result += "\n```\(lang)\n\(content)\n```\n"
                    } else {
                        result += "\n```\n\(content)\n```\n"
                    }

                case "blockquote":
                    let content = try convertElement(childElement)
                    let lines = content.split(separator: "\n")
                    for line in lines {
                        result += "> \(line)\n"
                    }
                    result += "\n"

                case "ul":
                    result += try convertList(childElement, ordered: false)

                case "ol":
                    result += try convertList(childElement, ordered: true)

                case "li":
                    // Should be handled by ul/ol
                    let content = try convertElement(childElement)
                    result += content

                case "h1":
                    let content = try convertElement(childElement)
                    result += "\n# \(content)\n"

                case "h2":
                    let content = try convertElement(childElement)
                    result += "\n## \(content)\n"

                case "h3":
                    let content = try convertElement(childElement)
                    result += "\n### \(content)\n"

                case "h4":
                    let content = try convertElement(childElement)
                    result += "\n#### \(content)\n"

                case "h5":
                    let content = try convertElement(childElement)
                    result += "\n##### \(content)\n"

                case "h6":
                    let content = try convertElement(childElement)
                    result += "\n###### \(content)\n"

                case "img":
                    let alt = try? childElement.attr("alt")
                    let src = try? childElement.attr("src")
                    if let src = src {
                        result += "![\(alt ?? "image")](\(src))"
                    }

                case "hr":
                    result += "\n---\n"

                // Table support
                case "table":
                    result += try convertTable(childElement)

                case "thead", "tbody", "tfoot":
                    // These are handled by table, but if encountered alone, process children
                    result += try convertElement(childElement)

                case "tr", "th", "td":
                    // These should be handled by table, but if encountered alone, process children
                    result += try convertElement(childElement)

                // Strikethrough
                case "del", "s", "strike":
                    let content = try convertElement(childElement)
                    result += "~~\(content)~~"

                // Underline - no standard markdown, preserve as HTML for custom renderer
                case "u", "ins":
                    let content = try convertElement(childElement)
                    result += "<u>\(content)</u>"

                // Superscript/subscript - preserve as HTML for custom renderer
                case "sup":
                    let content = try convertElement(childElement)
                    result += "<sup>\(content)</sup>"

                case "sub":
                    let content = try convertElement(childElement)
                    result += "<sub>\(content)</sub>"

                // Mark/highlight - render with markers
                case "mark":
                    let content = try convertElement(childElement)
                    result += "==\(content)=="

                // Definition list
                case "dl":
                    result += try convertDefinitionList(childElement)

                case "dt":
                    let content = try convertElement(childElement)
                    result += "\n**\(content)**\n"

                case "dd":
                    let content = try convertElement(childElement)
                    result += ": \(content)\n"

                // Abbreviation - just show the text with title
                case "abbr":
                    let content = try convertElement(childElement)
                    if let title = try? childElement.attr("title"), !title.isEmpty {
                        result += "\(content) (\(title))"
                    } else {
                        result += content
                    }

                // Citation
                case "cite":
                    let content = try convertElement(childElement)
                    result += "*\(content)*"

                // Keyboard input
                case "kbd":
                    let content = try convertElement(childElement)
                    result += "`\(content)`"

                // Sample output
                case "samp":
                    let content = try convertElement(childElement)
                    result += "`\(content)`"

                // Variable
                case "var":
                    let content = try convertElement(childElement)
                    result += "*\(content)*"

                // Small text
                case "small":
                    let content = try convertElement(childElement)
                    result += content

                // Figure and figcaption
                case "figure":
                    result += try convertElement(childElement)

                case "figcaption":
                    let content = try convertElement(childElement)
                    result += "\n*\(content)*\n"

                // Address
                case "address":
                    let content = try convertElement(childElement)
                    result += "\n*\(content)*\n"

                // Time - just show the text
                case "time":
                    let content = try convertElement(childElement)
                    result += content

                // Details/summary - collapsible sections
                case "details":
                    result += try convertElement(childElement)

                case "summary":
                    let content = try convertElement(childElement)
                    result += "\n**\(content)**\n"

                // Input elements (checkboxes for task lists)
                case "input":
                    let inputType = (try? childElement.attr("type"))?.lowercased() ?? ""
                    if inputType == "checkbox" {
                        let isChecked = childElement.hasAttr("checked")
                        result += isChecked ? "[x] " : "[ ] "
                    }
                    // Other input types are ignored (form elements don't render in content)

                // Label elements - just show the text content
                case "label":
                    result += try convertElement(childElement)

                // Container elements - just process children
                case "div", "span", "body", "html", "article", "section", "nav", "aside",
                     "header", "footer", "main", "caption":
                    result += try convertElement(childElement)

                default:
                    // Unsupported tag
                    try RenderError.handleUnsupportedTag(
                        tagName,
                        context: String(childElement.outerHtml().prefix(100)),
                        crashOnUnsupportedTags: crashOnUnsupportedTags
                    )

                    // If we get here (didn't crash), just include the text content
                    result += try convertElement(childElement)
                }
            }
        }

        return result
    }

    /// Convert list to Markdown
    private func convertList(_ element: Element, ordered: Bool) throws -> String {
        var result = "\n"
        let items = try element.select("li")

        for (index, item) in items.enumerated() {
            let content = try convertElement(item)
            if ordered {
                result += "\(index + 1). \(content)\n"
            } else {
                result += "- \(content)\n"
            }
        }

        result += "\n"
        return result
    }

    /// Convert table to Markdown
    private func convertTable(_ element: Element) throws -> String {
        var result = "\n"
        var rows: [[String]] = []

        // Get all rows from thead and tbody
        let allRows = try element.select("tr")

        for row in allRows {
            var cells: [String] = []

            // Get th and td cells
            for cell in row.children() {
                let tagName = cell.tagName().lowercased()
                if tagName == "th" || tagName == "td" {
                    let content = try convertElement(cell)
                        .replacingOccurrences(of: "\n", with: " ")
                        .replacingOccurrences(of: "|", with: "\\|") // Escape pipes for Markdown tables
                        .trimmingCharacters(in: .whitespaces)
                    cells.append(content)
                }
            }

            if !cells.isEmpty {
                rows.append(cells)
            }
        }

        guard !rows.isEmpty else { return "" }

        // Calculate column widths
        let columnCount = rows.map { $0.count }.max() ?? 0
        guard columnCount > 0 else { return "" }

        // Normalize rows to have the same column count
        let normalizedRows = rows.map { row -> [String] in
            var normalized = row
            while normalized.count < columnCount {
                normalized.append("")
            }
            return normalized
        }

        // Build markdown table
        for (index, row) in normalizedRows.enumerated() {
            result += "| " + row.joined(separator: " | ") + " |\n"

            // Add separator after header row
            if index == 0 {
                let separator = Array(repeating: "---", count: columnCount)
                result += "| " + separator.joined(separator: " | ") + " |\n"
            }
        }

        result += "\n"
        return result
    }

    /// Convert definition list to Markdown
    private func convertDefinitionList(_ element: Element) throws -> String {
        var result = "\n"

        for child in element.children() {
            let tagName = child.tagName().lowercased()
            let content = try convertElement(child)

            switch tagName {
            case "dt":
                result += "\n**\(content)**\n"
            case "dd":
                result += ": \(content)\n"
            default:
                result += content
            }
        }

        result += "\n"
        return result
    }

    /// Escape special Markdown characters
    private func escapeMarkdown(_ text: String) -> String {
        // Only escape characters that would cause markdown parsing issues
        // Don't escape common characters like . and - as they rarely cause problems
        // and escaping them breaks URLs and normal text readability

        // Don't escape inside code blocks
        if text.contains("```") || text.contains("`") {
            return text
        }

        // Preserve markdown image syntax ![alt](url) and link syntax [text](url)
        // by splitting text around these patterns
        // Use a single regex pass to find both images and links (images start with !)
        let combinedPattern = /!?\[[^\]]*\]\([^)]+\)/

        var result = ""
        var currentIndex = text.startIndex

        // Find all markdown image and link patterns to preserve
        var preservedRanges: [(Range<String.Index>, String)] = []
        var searchStart = text.startIndex
        while let match = text[searchStart...].firstMatch(of: combinedPattern) {
            preservedRanges.append((match.range, String(match.output)))
            searchStart = match.range.upperBound
        }

        // Build result by escaping text between preserved ranges
        for (range, preserved) in preservedRanges {
            // Escape text before this preserved range
            if currentIndex < range.lowerBound {
                let textBefore = String(text[currentIndex..<range.lowerBound])
                result += escapeMarkdownCharacters(textBefore)
            }
            // Add preserved markdown syntax as-is
            result += preserved
            currentIndex = range.upperBound
        }

        // Escape remaining text after last preserved range
        if currentIndex < text.endIndex {
            let remainingText = String(text[currentIndex...])
            result += escapeMarkdownCharacters(remainingText)
        }

        return result
    }

    /// Escape markdown characters in plain text (not in markdown syntax)
    private func escapeMarkdownCharacters(_ text: String) -> String {
        var escaped = text
        // Only escape characters that actually cause markdown parsing issues
        // Don't escape [ ] as they only form links when followed by (url)
        let charactersToEscape = ["\\", "*", "_"]
        for char in charactersToEscape {
            escaped = escaped.replacingOccurrences(of: char, with: "\\\(char)")
        }
        return escaped
    }

    /// Clean up Markdown output
    private func cleanupMarkdown(_ markdown: String) -> String {
        var cleaned = markdown

        // Remove leading markdown line breaks (  \n pattern at start)
        // This handles HTML that starts with multiple <br> tags
        while cleaned.hasPrefix("  \n") {
            cleaned = String(cleaned.dropFirst(3))
        }

        // Remove excessive newlines (more than 2 consecutive)
        cleaned = cleaned.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )

        // Remove excessive spaces followed by newlines (softens br handling)
        cleaned = cleaned.replacingOccurrences(
            of: #"(  \n){2,}"#,
            with: "  \n",
            options: .regularExpression
        )

        // Trim whitespace and newlines from start and end
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
    }
}