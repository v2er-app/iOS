//
//  RichContentView.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

/// Enhanced RichView that properly renders images, code blocks, and complex content
@available(iOS 18.0, macOS 15.0, *)
public struct RichContentView: View {

    // MARK: - Properties

    private let htmlContent: String
    private var configuration: RenderConfiguration

    @State private var contentElements: [ContentElement] = []
    @State private var isLoading = true
    @State private var error: RenderError?
    @State private var renderMetadata: RenderMetadata?

    // Actor for background rendering
    private let renderActor = RenderActor()

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

        // Pre-fill from shared cache so recreated views never flash a loading state.
        // This prevents List scroll-position jumps caused by brief height collapse.
        if let cached = RichViewCache.shared.getContentElements(forHTML: htmlContent) {
            _contentElements = State(initialValue: cached)
            _isLoading = State(initialValue: false)
        }
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
                VStack(alignment: .leading, spacing: configuration.stylesheet.body.paragraphSpacing) {
                    ForEach(Array(groupedElements.enumerated()), id: \.offset) { _, group in
                        renderGroup(group)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No content")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await parseContent()
        }
    }

    // MARK: - Grouping

    /// Groups consecutive text and heading elements so they render in a single UITextView for cross-paragraph selection.
    /// Only non-text elements (images, code blocks, tables, rules) break the group.
    private var groupedElements: [ElementGroup] {
        var groups: [ElementGroup] = []
        var pendingTexts: [AttributedString] = []

        for element in contentElements {
            switch element.type {
            case .text(let attr):
                pendingTexts.append(attr)
            case .heading(let text, let level):
                var headingAttr = AttributedString(text)
                headingAttr.setCrossplatformFont(size: sizeForHeading(level), weight: configuration.stylesheet.heading.fontWeight)
                headingAttr.foregroundColor = configuration.stylesheet.heading.color.uiColor
                pendingTexts.append(headingAttr)
            case .horizontalRule:
                if !pendingTexts.isEmpty {
                    pendingTexts.append(AttributedString("───────────────────\n"))
                } else {
                    groups.append(.single(element))
                }
            default:
                if !pendingTexts.isEmpty {
                    groups.append(.mergedText(pendingTexts))
                    pendingTexts = []
                }
                groups.append(.single(element))
            }
        }
        if !pendingTexts.isEmpty {
            groups.append(.mergedText(pendingTexts))
        }
        return groups
    }

    // MARK: - Rendering

    @ViewBuilder
    private func renderGroup(_ group: ElementGroup) -> some View {
        switch group {
        case .mergedText(let strings):
            let merged = mergeAttributedStrings(strings)
            SelectableTextView(
                attributedString: merged,
                fontSize: configuration.stylesheet.body.fontSize,
                lineSpacing: configuration.stylesheet.body.lineSpacing,
                onLinkTapped: onLinkTapped
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        case .single(let element):
            renderElement(element)
        }
    }

    private func mergeAttributedStrings(_ strings: [AttributedString]) -> AttributedString {
        var result = AttributedString()
        for (index, str) in strings.enumerated() {
            if index > 0 {
                result.append(AttributedString("\n\n"))
            }
            result.append(str)
        }
        return result
    }

    @ViewBuilder
    private func renderElement(_ element: ContentElement) -> some View {
        switch element.type {
        case .text:
            EmptyView()

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

        case .horizontalRule:
            Rectangle()
                .fill(configuration.stylesheet.horizontalRule.color)
                .frame(height: configuration.stylesheet.horizontalRule.height)
                .padding(.vertical, configuration.stylesheet.horizontalRule.verticalPadding)

        case .table(let rows, let hasHeader):
            TableElementView(
                rows: rows,
                hasHeader: hasHeader,
                style: configuration.stylesheet.table,
                bodyStyle: configuration.stylesheet.body
            )
        }
    }

    private func fontForHeading(_ level: Int) -> Font {
        return .system(size: sizeForHeading(level))
    }

    private func sizeForHeading(_ level: Int) -> CGFloat {
        switch level {
        case 1: return configuration.stylesheet.heading.h1Size
        case 2: return configuration.stylesheet.heading.h2Size
        case 3: return configuration.stylesheet.heading.h3Size
        case 4: return configuration.stylesheet.heading.h4Size
        case 5: return configuration.stylesheet.heading.h5Size
        case 6: return configuration.stylesheet.heading.h6Size
        default: return configuration.stylesheet.heading.h1Size
        }
    }

    @MainActor
    private func parseContent() async {
        // Already populated (e.g. from cache in init) — skip re-parse.
        guard contentElements.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            // Use actor for background rendering with caching
            let result = try await renderActor.render(
                html: htmlContent,
                configuration: configuration
            )

            self.contentElements = result.elements
            self.renderMetadata = result.metadata
            self.isLoading = false

            onRenderCompleted?(result.metadata)

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

}

// MARK: - Element Group

enum ElementGroup {
    case mergedText([AttributedString])
    case single(ContentElement)
}

// MARK: - Content Element

public struct ContentElement: Identifiable {
    public let id = UUID()
    public let type: ElementType

    public init(type: ElementType) {
        self.type = type
    }

    public enum ElementType {
        case text(AttributedString)
        case codeBlock(code: String, language: String?)
        case image(ImageInfo)
        case heading(text: String, level: Int)
        case horizontalRule
        case table(rows: [[String]], hasHeader: Bool)

        var isImage: Bool {
            if case .image = self { return true }
            return false
        }
    }
}

// MARK: - Configuration

@available(iOS 18.0, macOS 15.0, *)
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

// MARK: - Table Element View

@available(iOS 18.0, macOS 15.0, *)
struct TableElementView: View {
    let rows: [[String]]
    let hasHeader: Bool
    let style: TableStyle
    let bodyStyle: TextStyle

    var body: some View {
        if rows.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    let isHeader = hasHeader && rowIndex == 0

                    HStack(spacing: 0) {
                        ForEach(Array(row.enumerated()), id: \.offset) { cellIndex, cell in
                            Text(cell)
                                .font(.system(size: bodyStyle.fontSize, weight: isHeader ? style.headerFontWeight : bodyStyle.fontWeight))
                                .foregroundColor(bodyStyle.color)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(style.cellPadding)
                                .background(isHeader ? style.headerBackgroundColor : Color.clear)

                            if cellIndex < row.count - 1 {
                                Rectangle()
                                    .fill(style.separatorColor)
                                    .frame(width: style.separatorWidth)
                            }
                        }
                    }

                    if rowIndex < rows.count - 1 {
                        Rectangle()
                            .fill(style.separatorColor)
                            .frame(height: style.separatorWidth)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(style.separatorColor, lineWidth: style.separatorWidth)
            )
        }
    }
}