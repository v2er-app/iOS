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
                    result += "\n\n\(content)\n\n"

                case "br":
                    result += "  \n"

                case "strong", "b":
                    let content = try convertElement(childElement)
                    result += "**\(content)**"

                case "em", "i":
                    let content = try convertElement(childElement)
                    result += "*\(content)*"

                case "a":
                    // Get raw text without escaping for links
                    let text = try childElement.text()
                    if let href = try? childElement.attr("href") {
                        result += "[\(text)](\(href))"
                    } else {
                        result += text
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

                // Container elements - just process children
                case "div", "span", "body", "html":
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

    /// Escape special Markdown characters
    private func escapeMarkdown(_ text: String) -> String {
        // Only escape characters that would cause markdown parsing issues
        // Don't escape common characters like . and - as they rarely cause problems
        // and escaping them breaks URLs and normal text readability
        var escaped = text

        // Don't escape inside code blocks
        if !text.contains("```") && !text.contains("`") {
            // Only escape the most problematic markdown characters
            // Avoid escaping . and - as they appear frequently in URLs and text
            let charactersToEscape = ["\\", "*", "_", "[", "]"]
            for char in charactersToEscape {
                escaped = escaped.replacingOccurrences(of: char, with: "\\\(char)")
            }
        }

        return escaped
    }

    /// Clean up Markdown output
    private func cleanupMarkdown(_ markdown: String) -> String {
        var cleaned = markdown

        // Remove excessive newlines (more than 2 consecutive)
        cleaned = cleaned.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )

        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
    }
}