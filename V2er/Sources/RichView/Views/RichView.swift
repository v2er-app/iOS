//
//  RichView.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

/// A SwiftUI view for rendering HTML content as rich text
@available(iOS 15.0, *)
public struct RichView: View {

    // MARK: - Properties

    /// HTML content to render
    private let htmlContent: String

    /// Rendering configuration
    private var configuration: RenderConfiguration

    /// Rendered AttributedString
    @State private var attributedString: AttributedString?

    /// Loading state
    @State private var isLoading = true

    /// Error state
    @State private var error: RenderError?

    /// Render metadata
    @State private var metadata: RenderMetadata?

    // MARK: - Events

    /// Called when a link is tapped
    public var onLinkTapped: ((URL) -> Void)?

    /// Called when a @mention is tapped
    public var onMentionTapped: ((String) -> Void)?

    /// Called when rendering starts
    public var onRenderStarted: (() -> Void)?

    /// Called when rendering completes
    public var onRenderCompleted: ((RenderMetadata) -> Void)?

    /// Called when rendering fails
    public var onRenderFailed: ((RenderError) -> Void)?

    // MARK: - Initialization

    /// Initialize with HTML content
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
            } else if let attributedString = attributedString {
                Text(attributedString)
                    .font(.system(size: configuration.stylesheet.body.fontSize))
                    .lineSpacing(configuration.stylesheet.body.lineSpacing)
                    .environment(\.openURL, OpenURLAction { url in
                        onLinkTapped?(url)
                        return .handled
                    })
            } else {
                Text("No content")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await renderContent()
        }
    }

    // MARK: - Rendering

    @MainActor
    private func renderContent() async {
        let startTime = Date()
        onRenderStarted?()
        isLoading = true
        error = nil

        do {
            // Convert HTML to Markdown
            let converter = HTMLToMarkdownConverter(
                crashOnUnsupportedTags: configuration.crashOnUnsupportedTags
            )
            let markdown = try converter.convert(htmlContent)

            // Render Markdown to AttributedString
            let renderer = MarkdownRenderer(
                stylesheet: configuration.stylesheet,
                enableCodeHighlighting: configuration.enableCodeHighlighting
            )
            let rendered = try renderer.render(markdown)

            // Update state
            self.attributedString = rendered
            self.isLoading = false

            // Create metadata
            let endTime = Date()
            let renderTime = endTime.timeIntervalSince(startTime)
            let metadata = RenderMetadata(
                renderTime: renderTime,
                htmlLength: htmlContent.count,
                markdownLength: markdown.count,
                attributedStringLength: rendered.characters.count,
                cacheHit: false,
                imageCount: 0,
                linkCount: 0,
                mentionCount: 0
            )
            self.metadata = metadata

            onRenderCompleted?(metadata)

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

// MARK: - Configuration

@available(iOS 15.0, *)
extension RichView {

    /// Apply configuration to the view
    public func configuration(_ config: RenderConfiguration) -> Self {
        var view = self
        view.configuration = config
        return view
    }

    /// Apply custom stylesheet
    public func stylesheet(_ stylesheet: RenderStylesheet) -> Self {
        var view = self
        view.configuration.stylesheet = stylesheet
        return view
    }

    /// Set link tap handler
    public func onLinkTapped(_ action: @escaping (URL) -> Void) -> Self {
        var view = self
        view.onLinkTapped = action
        return view
    }

    /// Set mention tap handler
    public func onMentionTapped(_ action: @escaping (String) -> Void) -> Self {
        var view = self
        view.onMentionTapped = action
        return view
    }

    /// Set render started handler
    public func onRenderStarted(_ action: @escaping () -> Void) -> Self {
        var view = self
        view.onRenderStarted = action
        return view
    }

    /// Set render completed handler
    public func onRenderCompleted(_ action: @escaping (RenderMetadata) -> Void) -> Self {
        var view = self
        view.onRenderCompleted = action
        return view
    }

    /// Set render failed handler
    public func onRenderFailed(_ action: @escaping (RenderError) -> Void) -> Self {
        var view = self
        view.onRenderFailed = action
        return view
    }
}

// MARK: - Error View

@available(iOS 15.0, *)
struct ErrorView: View {
    let error: RenderError

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("Rendering Error")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Render Metadata

/// Metadata about the rendering process
public struct RenderMetadata {
    /// Time taken to render (in seconds)
    public let renderTime: TimeInterval

    /// Original HTML content length
    public let htmlLength: Int

    /// Converted Markdown length
    public let markdownLength: Int

    /// Final AttributedString length
    public let attributedStringLength: Int

    /// Whether the result was retrieved from cache
    public let cacheHit: Bool

    /// Number of images in the content
    public let imageCount: Int

    /// Number of links in the content
    public let linkCount: Int

    /// Number of @mentions in the content
    public let mentionCount: Int
}