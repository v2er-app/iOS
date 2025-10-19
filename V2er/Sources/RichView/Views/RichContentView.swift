//
//  RichContentView.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

/// Enhanced RichView that properly renders images, code blocks, and complex content
@available(iOS 15.0, *)
public struct RichContentView: View {

    // MARK: - Properties

    private let htmlContent: String
    private var configuration: RenderConfiguration

    @State private var contentElements: [ContentElement] = []
    @State private var isLoading = true
    @State private var error: RenderError?

    // MARK: - Events

    public var onLinkTapped: ((URL) -> Void)?
    public var onMentionTapped: ((String) -> Void)?
    public var onImageTapped: ((URL) -> Void)?
    public var onRenderCompleted: ((RenderMetadata) -> Void)?
    public var onRenderFailed: ((RenderError) -> Void)?

    // MARK: - Initialization

    public init(htmlContent: String) {
        self.htmlContent = htmlContent
        self.configuration = .default
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                ErrorView(error: error)
            } else if !contentElements.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: configuration.stylesheet.body.paragraphSpacing) {
                        ForEach(contentElements) { element in
                            renderElement(element)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text("No content")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await parseContent()
        }
    }

    // MARK: - Rendering

    @ViewBuilder
    private func renderElement(_ element: ContentElement) -> some View {
        switch element.type {
        case .text(let attributedString):
            Text(attributedString)
                .font(.system(size: configuration.stylesheet.body.fontSize))
                .lineSpacing(configuration.stylesheet.body.lineSpacing)
                .textSelection(.enabled)

        case .codeBlock(let code, let language):
            CodeBlockAttachment(
                code: code,
                language: language,
                style: configuration.stylesheet.code,
                enableHighlighting: configuration.enableCodeHighlighting
            )

        case .image(let imageInfo):
            if configuration.enableImages {
                AsyncImageAttachment(
                    url: imageInfo.url,
                    altText: imageInfo.altText,
                    style: configuration.stylesheet.image,
                    quality: configuration.imageQuality
                )
                .onTapGesture {
                    if let url = imageInfo.url {
                        onImageTapped?(url)
                    }
                }
            }

        case .heading(let text, let level):
            Text(text)
                .font(fontForHeading(level))
                .fontWeight(configuration.stylesheet.heading.fontWeight)
                .foregroundColor(configuration.stylesheet.heading.color)
                .padding(.top, configuration.stylesheet.heading.topSpacing)
                .padding(.bottom, configuration.stylesheet.heading.bottomSpacing)
        }
    }

    private func fontForHeading(_ level: Int) -> Font {
        let size: CGFloat
        switch level {
        case 1: size = configuration.stylesheet.heading.h1Size
        case 2: size = configuration.stylesheet.heading.h2Size
        case 3: size = configuration.stylesheet.heading.h3Size
        case 4: size = configuration.stylesheet.heading.h4Size
        case 5: size = configuration.stylesheet.heading.h5Size
        case 6: size = configuration.stylesheet.heading.h6Size
        default: size = configuration.stylesheet.heading.h1Size
        }
        return .system(size: size)
    }

    @MainActor
    private func parseContent() async {
        isLoading = true
        error = nil

        do {
            // Convert HTML to Markdown
            let converter = HTMLToMarkdownConverter(
                crashOnUnsupportedTags: configuration.crashOnUnsupportedTags
            )
            let markdown = try converter.convert(htmlContent)

            // Parse markdown into content elements
            let elements = try parseMarkdownToElements(markdown)
            self.contentElements = elements
            self.isLoading = false

            onRenderCompleted?(RenderMetadata(
                renderTime: 0,
                htmlLength: htmlContent.count,
                markdownLength: markdown.count,
                attributedStringLength: 0,
                cacheHit: false,
                imageCount: elements.filter { $0.type.isImage }.count,
                linkCount: 0,
                mentionCount: 0
            ))

        } catch let renderError as RenderError {
            self.error = renderError
            self.isLoading = false
            onRenderFailed?(renderError)
        } catch {
            let renderError = RenderError.renderingFailed(error.localizedDescription)
            self.error = renderError
            self.isLoading = false
            onRenderFailed?(renderError)
        }
    }

    private func parseMarkdownToElements(_ markdown: String) throws -> [ContentElement] {
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

            // Regular text paragraph
            let renderer = MarkdownRenderer(
                stylesheet: configuration.stylesheet,
                enableCodeHighlighting: configuration.enableCodeHighlighting
            )
            let attributed = try renderer.render(line)
            if !attributed.characters.isEmpty {
                elements.append(ContentElement(type: .text(attributed)))
            }

            index += 1
        }

        return elements
    }
}

// MARK: - Content Element

struct ContentElement: Identifiable {
    let id = UUID()
    let type: ElementType

    enum ElementType {
        case text(AttributedString)
        case codeBlock(code: String, language: String?)
        case image(ImageInfo)
        case heading(text: String, level: Int)

        var isImage: Bool {
            if case .image = self { return true }
            return false
        }
    }
}

// MARK: - Configuration

@available(iOS 15.0, *)
extension RichContentView {

    public func configuration(_ config: RenderConfiguration) -> Self {
        var view = self
        view.configuration = config
        return view
    }

    public func onLinkTapped(_ action: @escaping (URL) -> Void) -> Self {
        var view = self
        view.onLinkTapped = action
        return view
    }

    public func onMentionTapped(_ action: @escaping (String) -> Void) -> Self {
        var view = self
        view.onMentionTapped = action
        return view
    }

    public func onImageTapped(_ action: @escaping (URL) -> Void) -> Self {
        var view = self
        view.onImageTapped = action
        return view
    }

    public func onRenderCompleted(_ action: @escaping (RenderMetadata) -> Void) -> Self {
        var view = self
        view.onRenderCompleted = action
        return view
    }

    public func onRenderFailed(_ action: @escaping (RenderError) -> Void) -> Self {
        var view = self
        view.onRenderFailed = action
        return view
    }
}