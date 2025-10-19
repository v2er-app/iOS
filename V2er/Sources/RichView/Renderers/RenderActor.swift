//
//  RenderActor.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation
import SwiftUI

/// Actor for thread-safe background rendering
@available(iOS 15.0, *)
public actor RenderActor {

    // MARK: - Properties

    private let cache: RichViewCache
    private var activeRenderTasks: [String: Task<RenderResult, Error>] = [:]

    // MARK: - Initialization

    public init(cache: RichViewCache = .shared) {
        self.cache = cache
    }

    // MARK: - Rendering

    /// Render HTML content to AttributedString in background
    public func render(
        html: String,
        configuration: RenderConfiguration
    ) async throws -> RenderResult {
        let startTime = Date()

        // Check if already rendering
        if let existingTask = activeRenderTasks[html] {
            return try await existingTask.value
        }

        // Create render task
        let task = Task<RenderResult, Error> {
            defer {
                Task {
                    await self.removeActiveTask(for: html)
                }
            }

            // Try cache first
            if configuration.enableCaching {
                if let cached = cache.getContentElements(forHTML: html) {
                    return RenderResult(
                        elements: cached,
                        metadata: RenderMetadata(
                            renderTime: Date().timeIntervalSince(startTime),
                            htmlLength: html.count,
                            markdownLength: 0,
                            attributedStringLength: 0,
                            cacheHit: true,
                            imageCount: cached.filter { $0.type.isImage }.count,
                            linkCount: 0,
                            mentionCount: 0
                        )
                    )
                }
            }

            // Convert HTML to Markdown
            let markdown: String
            if configuration.enableCaching,
               let cachedMarkdown = cache.getMarkdown(forHTML: html) {
                markdown = cachedMarkdown
            } else {
                let converter = HTMLToMarkdownConverter(
                    crashOnUnsupportedTags: configuration.crashOnUnsupportedTags
                )
                markdown = try converter.convert(html)
                if configuration.enableCaching {
                    cache.setMarkdown(markdown, forHTML: html)
                }
            }

            // Parse to content elements
            let elements = try self.parseMarkdownToElements(
                markdown,
                configuration: configuration
            )

            // Cache elements
            if configuration.enableCaching {
                cache.setContentElements(elements, forHTML: html)
            }

            let endTime = Date()
            let renderTime = endTime.timeIntervalSince(startTime)

            return RenderResult(
                elements: elements,
                metadata: RenderMetadata(
                    renderTime: renderTime,
                    htmlLength: html.count,
                    markdownLength: markdown.count,
                    attributedStringLength: 0,
                    cacheHit: false,
                    imageCount: elements.filter { $0.type.isImage }.count,
                    linkCount: 0,
                    mentionCount: 0
                )
            )
        }

        activeRenderTasks[html] = task
        return try await task.value
    }

    /// Cancel all active render tasks
    public func cancelAll() {
        for task in activeRenderTasks.values {
            task.cancel()
        }
        activeRenderTasks.removeAll()
    }

    /// Cancel specific render task
    public func cancel(for html: String) {
        activeRenderTasks[html]?.cancel()
        activeRenderTasks.removeValue(forKey: html)
    }

    // MARK: - Private Methods

    private func removeActiveTask(for html: String) {
        activeRenderTasks.removeValue(forKey: html)
    }

    private func parseMarkdownToElements(
        _ markdown: String,
        configuration: RenderConfiguration
    ) throws -> [ContentElement] {
        var elements: [ContentElement] = []
        let lines = markdown.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            let line = lines[index]

            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                index += 1
                continue
            }

            // Code block
            if line.starts(with: "```") {
                let language = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var code = ""
                index += 1

                while index < lines.count && !lines[index].starts(with: "```") {
                    code += lines[index] + "\n"
                    index += 1
                }

                let detectedLanguage = language.isEmpty ? LanguageDetector.detectLanguage(from: code) : language
                elements.append(ContentElement(
                    type: .codeBlock(code: code.trimmingCharacters(in: .whitespacesAndNewlines), language: detectedLanguage)
                ))
                index += 1
                continue
            }

            // Heading
            if let headingMatch = line.firstMatch(of: /^(#{1,6})\s+(.+)/) {
                let level = headingMatch.1.count
                let text = String(headingMatch.2)
                elements.append(ContentElement(type: .heading(text: text, level: level)))
                index += 1
                continue
            }

            // Image
            // TODO: Reimplement with iOS 15 compatible regex
            /* iOS 16+ only
            if let imageMatch = line.firstMatch(of: /!\[([^\]]*)\]\(([^)]+)\)/) {
                let altText = String(imageMatch.1)
                let urlString = String(imageMatch.2)
                let url = URL(string: urlString)
                elements.append(ContentElement(
                    type: .image(ImageInfo(url: url, altText: altText))
                ))
                index += 1
                continue
            }
            */

            // Regular text paragraph
            // TODO: Use MarkdownRenderer once iOS 15 compatible
            var attributed = AttributedString(line)
            attributed.font = .system(size: configuration.stylesheet.body.fontSize)
            attributed.foregroundColor = configuration.stylesheet.body.color
            if !attributed.characters.isEmpty {
                elements.append(ContentElement(type: .text(attributed)))
            }

            index += 1
        }

        return elements
    }
}

// MARK: - Render Result

@available(iOS 15.0, *)
public struct RenderResult {
    public let elements: [ContentElement]
    public let metadata: RenderMetadata
}