# RichView Module API Definition

## 📋 Overview

This document defines the public API surface for the RichView module. The module follows strict access control principles:
- **Public**: Only essential interfaces exposed to consumers
- **Internal**: Implementation details accessible within the module
- **Fileprivate**: Helper code scoped to individual files

## 🎯 Design Principles

1. **Minimal Public Surface**: Only expose what consumers need
2. **Type Safety**: Use enums and structs to prevent invalid states
3. **Composability**: Allow flexible configuration through options
4. **Event-Driven**: Use closures for handling user interactions
5. **SwiftUI Native**: Seamless integration with SwiftUI views

---

## 📦 Public API

### 1. RichView (Main Component)

The primary entry point for rich text rendering.

```swift
/// RichView - Native rich text renderer for V2EX content
///
/// Renders V2EX HTML content using native SwiftUI/UIKit components
/// with support for images, code highlighting, and interactive elements.
///
/// Example:
/// ```swift
/// RichView(htmlContent: post.content) { event in
///     switch event {
///     case .linkTapped(let url):
///         openURL(url)
///     case .imageTapped(let url):
///         showImagePreview(url)
///     case .mentionTapped(let username):
///         navigateToProfile(username)
///     }
/// }
/// .configuration(.default)
/// ```
public struct RichView: View {

    // MARK: - Initializers

    /// Create a RichView with HTML content
    /// - Parameters:
    ///   - htmlContent: V2EX HTML content string
    ///   - configuration: Rendering configuration (optional, defaults to .default)
    ///   - onEvent: Event handler for user interactions (optional)
    public init(
        htmlContent: String,
        configuration: RenderConfiguration = .default,
        onEvent: ((RichViewEvent) -> Void)? = nil
    )

    // MARK: - View Body

    public var body: some View { get }
}

// MARK: - View Modifiers

public extension RichView {

    /// Apply custom render configuration
    /// - Parameter configuration: Render configuration
    /// - Returns: Modified view
    func configuration(_ configuration: RenderConfiguration) -> Self

    /// Set event handler
    /// - Parameter handler: Event handler closure
    /// - Returns: Modified view
    func onEvent(_ handler: @escaping (RichViewEvent) -> Void) -> Self
}
```

---

### 2. RenderConfiguration

Configuration options for customizing rendering behavior.

```swift
/// Configuration for RichView rendering
public struct RenderConfiguration: Equatable {

    // MARK: - Stylesheet-based Configuration

    /// Custom stylesheet for fine-grained style control
    /// Provides CSS-like styling capabilities
    public var stylesheet: RenderStylesheet

    // MARK: - Behavior

    /// Enable image loading (default: true)
    public var enableImages: Bool

    /// Enable code syntax highlighting (default: true)
    public var enableCodeHighlighting: Bool

    /// Enable text selection (default: true)
    public var enableTextSelection: Bool

    /// Maximum image height (default: 300)
    public var maxImageHeight: CGFloat

    // MARK: - Performance

    /// Enable render caching (default: true)
    public var enableCaching: Bool

    /// Cache size limit in MB (default: 50)
    public var cacheSizeLimit: Int

    // MARK: - Error Handling

    /// Crash on unsupported tags in DEBUG builds (default: true)
    /// In RELEASE, errors are caught and logged
    public var crashOnUnsupportedTags: Bool

    // MARK: - Presets

    /// Default configuration
    public static let `default`: RenderConfiguration

    /// Compact configuration (smaller fonts, tighter spacing)
    public static let compact: RenderConfiguration

    /// Large accessibility configuration
    public static let largeAccessibility: RenderConfiguration

    /// Plain text only (no images, no highlighting)
    public static let plainText: RenderConfiguration

    // MARK: - Initializers

    /// Create custom configuration
    public init(
        stylesheet: RenderStylesheet = .default,
        enableImages: Bool = true,
        enableCodeHighlighting: Bool = true,
        enableTextSelection: Bool = true,
        maxImageHeight: CGFloat = 300,
        crashOnUnsupportedTags: Bool = true,
        enableCaching: Bool = true,
        cacheSizeLimit: Int = 50
    )
}
```

---

### 3. RenderStylesheet

CSS-like stylesheet for fine-grained style control.

```swift
/// Stylesheet for rich text rendering
/// Provides CSS-like styling capabilities with element-specific rules
public struct RenderStylesheet: Equatable {

    // MARK: - Element Styles

    /// Style for body text
    public var body: TextStyle

    /// Style for headings (h1-h6)
    public var heading: HeadingStyle

    /// Style for links
    public var link: LinkStyle

    /// Style for code (inline and blocks)
    public var code: CodeStyle

    /// Style for blockquotes
    public var blockquote: BlockquoteStyle

    /// Style for lists
    public var list: ListStyle

    /// Style for @mentions
    public var mention: MentionStyle

    /// Style for images
    public var image: ImageStyle

    // MARK: - Presets

    /// Default stylesheet (iOS system defaults)
    public static let `default`: RenderStylesheet

    /// Compact stylesheet (smaller fonts, tighter spacing)
    public static let compact: RenderStylesheet

    /// Large accessibility stylesheet
    public static let accessibility: RenderStylesheet

    // MARK: - Initializers

    public init(
        body: TextStyle = .default,
        heading: HeadingStyle = .default,
        link: LinkStyle = .default,
        code: CodeStyle = .default,
        blockquote: BlockquoteStyle = .default,
        list: ListStyle = .default,
        mention: MentionStyle = .default,
        image: ImageStyle = .default
    )
}

// MARK: - TextStyle

/// Style for body text
public struct TextStyle: Equatable {
    /// Font family (nil = system default)
    public var fontFamily: String?

    /// Font size
    public var fontSize: CGFloat

    /// Font weight
    public var fontWeight: Font.Weight

    /// Text color
    public var color: Color

    /// Line height multiplier (1.0 = default)
    public var lineHeight: CGFloat

    /// Paragraph spacing
    public var paragraphSpacing: CGFloat

    public static let `default`: TextStyle

    public init(
        fontFamily: String? = nil,
        fontSize: CGFloat = 16,
        fontWeight: Font.Weight = .regular,
        color: Color = .label,
        lineHeight: CGFloat = 1.4,
        paragraphSpacing: CGFloat = 12
    )
}

// MARK: - HeadingStyle

/// Style for headings with level-specific overrides
public struct HeadingStyle: Equatable {
    /// Base heading style
    public var base: TextStyle

    /// Level-specific overrides (h1-h6)
    public var levels: [Int: HeadingLevelStyle]

    public static let `default`: HeadingStyle

    public init(
        base: TextStyle = TextStyle(fontSize: 20, fontWeight: .bold),
        levels: [Int: HeadingLevelStyle] = [:]
    )
}

public struct HeadingLevelStyle: Equatable {
    public var fontSize: CGFloat
    public var fontWeight: Font.Weight
    public var color: Color?
    public var marginTop: CGFloat
    public var marginBottom: CGFloat

    public init(
        fontSize: CGFloat,
        fontWeight: Font.Weight = .bold,
        color: Color? = nil,
        marginTop: CGFloat = 16,
        marginBottom: CGFloat = 8
    )
}

// MARK: - LinkStyle

/// Style for links
public struct LinkStyle: Equatable {
    /// Link text color
    public var color: Color

    /// Underline style
    public var underlineStyle: UnderlineStyle

    /// Highlight color when tapped
    public var highlightColor: Color?

    public static let `default`: LinkStyle

    public init(
        color: Color = .systemBlue,
        underlineStyle: UnderlineStyle = .single,
        highlightColor: Color? = nil
    )

    public enum UnderlineStyle {
        case none
        case single
        case thick
        case double
    }
}

// MARK: - CodeStyle

/// Style for code (inline and blocks)
public struct CodeStyle: Equatable {
    // Inline code
    public var inlineFontFamily: String
    public var inlineFontSize: CGFloat
    public var inlineTextColor: Color
    public var inlineBackgroundColor: Color
    public var inlinePadding: EdgeInsets
    public var inlineCornerRadius: CGFloat

    // Code blocks
    public var blockFontFamily: String
    public var blockFontSize: CGFloat
    public var blockTextColor: Color
    public var blockBackgroundColor: Color
    public var blockPadding: EdgeInsets
    public var blockCornerRadius: CGFloat
    public var blockBorderWidth: CGFloat
    public var blockBorderColor: Color?

    // Syntax highlighting theme
    public var highlightTheme: HighlightTheme

    public static let `default`: CodeStyle

    public init(
        inlineFontFamily: String = "Menlo",
        inlineFontSize: CGFloat = 14,
        inlineTextColor: Color = .label,
        inlineBackgroundColor: Color = .systemGray6,
        inlinePadding: EdgeInsets = EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4),
        inlineCornerRadius: CGFloat = 3,
        blockFontFamily: String = "Menlo",
        blockFontSize: CGFloat = 13,
        blockTextColor: Color = .label,
        blockBackgroundColor: Color = .systemGray6,
        blockPadding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
        blockCornerRadius: CGFloat = 6,
        blockBorderWidth: CGFloat = 0,
        blockBorderColor: Color? = nil,
        highlightTheme: HighlightTheme = .github
    )

    public enum HighlightTheme: String {
        case github
        case githubDark
        case monokai
        case solarizedLight
        case solarizedDark
        case xcode
        case vs2015
        case atomOneDark
        case atomOneLight
    }
}

// MARK: - BlockquoteStyle

/// Style for blockquotes
public struct BlockquoteStyle: Equatable {
    /// Text color
    public var textColor: Color

    /// Background color
    public var backgroundColor: Color?

    /// Border width (left side)
    public var borderWidth: CGFloat

    /// Border color
    public var borderColor: Color

    /// Padding
    public var padding: EdgeInsets

    /// Font style (italic by default)
    public var fontStyle: Font.Design

    public static let `default`: BlockquoteStyle

    public init(
        textColor: Color = .secondaryLabel,
        backgroundColor: Color? = nil,
        borderWidth: CGFloat = 4,
        borderColor: Color = .systemGray4,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
        fontStyle: Font.Design = .default
    )
}

// MARK: - ListStyle

/// Style for lists (ordered and unordered)
public struct ListStyle: Equatable {
    /// Indent per level
    public var indentPerLevel: CGFloat

    /// Spacing between items
    public var itemSpacing: CGFloat

    /// Bullet style for unordered lists
    public var bulletStyle: BulletStyle

    /// Number format for ordered lists
    public var numberFormat: NumberFormat

    public static let `default`: ListStyle

    public init(
        indentPerLevel: CGFloat = 20,
        itemSpacing: CGFloat = 4,
        bulletStyle: BulletStyle = .disc,
        numberFormat: NumberFormat = .decimal
    )

    public enum BulletStyle {
        case disc       // •
        case circle     // ○
        case square     // ▪
        case custom(String)
    }

    public enum NumberFormat {
        case decimal    // 1. 2. 3.
        case roman      // i. ii. iii.
        case letter     // a. b. c.
    }
}

// MARK: - MentionStyle

/// Style for @mentions
public struct MentionStyle: Equatable {
    /// Text color
    public var color: Color

    /// Background color
    public var backgroundColor: Color?

    /// Font weight
    public var fontWeight: Font.Weight

    /// Corner radius for background
    public var cornerRadius: CGFloat

    /// Padding
    public var padding: EdgeInsets

    public static let `default`: MentionStyle

    public init(
        color: Color = .systemBlue,
        backgroundColor: Color? = nil,
        fontWeight: Font.Weight = .semibold,
        cornerRadius: CGFloat = 3,
        padding: EdgeInsets = EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
    )
}

// MARK: - ImageStyle

/// Style for images
public struct ImageStyle: Equatable {
    /// Maximum width (nil = full width)
    public var maxWidth: CGFloat?

    /// Maximum height
    public var maxHeight: CGFloat

    /// Corner radius
    public var cornerRadius: CGFloat

    /// Content mode
    public var contentMode: ContentMode

    /// Background color while loading
    public var placeholderColor: Color

    public static let `default`: ImageStyle

    public init(
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat = 300,
        cornerRadius: CGFloat = 6,
        contentMode: ContentMode = .fit,
        placeholderColor: Color = .systemGray5
    )

    public enum ContentMode {
        case fit
        case fill
    }
}
```

---

### 4. RichViewEvent

Events emitted by RichView for user interactions.

```swift
/// Events triggered by user interactions in RichView
public enum RichViewEvent: Equatable {

    /// User tapped a link
    /// - Parameter url: The URL of the tapped link
    case linkTapped(URL)

    /// User tapped an image
    /// - Parameter url: The URL of the tapped image
    case imageTapped(URL)

    /// User tapped a @mention
    /// - Parameter username: The mentioned username (without @)
    case mentionTapped(String)

    /// User long-pressed on text (for copy/share actions)
    /// - Parameter text: The selected text
    case textLongPressed(String)

    /// Rendering completed successfully
    /// - Parameter metadata: Render performance metadata
    case renderCompleted(RenderMetadata)

    /// Rendering failed
    /// - Parameter error: The error that occurred
    /// - Note: In DEBUG with `crashOnUnsupportedTags = true`, unsupported tags will crash before this event
    case renderFailed(RenderError)
}
```

---

### 4. RenderMetadata

Performance and diagnostic information about rendering.

```swift
/// Metadata about the rendering process
public struct RenderMetadata: Equatable {

    /// When the rendering completed
    public let timestamp: Date

    /// Total render time in milliseconds
    public let renderTime: TimeInterval

    /// Whether the result came from cache
    public let cacheHit: Bool

    /// Number of images in the content
    public let imageCount: Int

    /// Number of code blocks
    public let codeBlockCount: Int

    /// HTML content size in bytes
    public let contentSize: Int

    /// Generated AttributedString character count
    public let characterCount: Int

    /// Markdown intermediate representation (for debugging)
    public let markdownPreview: String?

    // MARK: - Computed Properties

    /// Human-readable render time description
    public var renderTimeDescription: String { get }

    /// Performance rating (Excellent/Good/Fair/Poor)
    public var performanceRating: PerformanceRating { get }
}

/// Performance rating categories
public enum PerformanceRating: String {
    case excellent  // < 50ms
    case good       // 50-100ms
    case fair       // 100-200ms
    case poor       // > 200ms
}
```

---

### 5. RenderError

Errors that can occur during rendering.

```swift
/// Errors that can occur during rich text rendering
///
/// ## Error Handling Policy
/// - **DEBUG builds**: Unsupported tags trigger `fatalError()` (crash)
/// - **RELEASE builds**: Errors are caught, logged, and event emitted
public enum RenderError: Error, LocalizedError {

    /// HTML parsing failed (SwiftSoup error)
    case htmlParsingFailed(String)

    /// Unsupported HTML tag encountered
    /// - In DEBUG: triggers crash if `crashOnUnsupportedTags = true`
    /// - In RELEASE: caught and logged
    case unsupportedTag(String, context: String)

    /// Markdown conversion failed
    case markdownConversionFailed(String, originalHTML: String)

    /// AttributedString rendering failed
    case renderingFailed(String)

    /// Image loading failed
    case imageLoadFailed(URL, Error)

    /// Invalid configuration
    case invalidConfiguration(String)

    // MARK: - Debug Assertions

    /// Triggers fatal error in DEBUG builds
    /// - Parameter message: Error message
    internal static func assertInDebug(_ message: String, file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        fatalError(message, file: file, line: line)
        #else
        print("[RichView Error] \(message)")
        #endif
    }

    // MARK: - LocalizedError

    public var errorDescription: String? { get }
    public var failureReason: String? { get }
    public var recoverySuggestion: String? { get }
}
```

---

### 6. RichViewCache (Global Cache Management)

Public interface for managing the global render cache.

```swift
/// Global cache manager for RichView rendering results
public final class RichViewCache {

    /// Shared singleton instance
    public static let shared: RichViewCache

    // MARK: - Cache Management

    /// Clear all cached render results
    public func clearAll()

    /// Clear cache for specific HTML content
    /// - Parameter htmlContent: The HTML content to clear
    public func clear(for htmlContent: String)

    /// Get current cache statistics
    public func statistics() -> CacheStatistics

    /// Set cache size limit
    /// - Parameter limitMB: Size limit in megabytes
    public func setSizeLimit(_ limitMB: Int)
}

/// Cache statistics
public struct CacheStatistics: Equatable {
    /// Current number of cached items
    public let itemCount: Int

    /// Approximate cache size in bytes
    public let sizeBytes: Int

    /// Cache hit rate (0.0-1.0)
    public let hitRate: Double

    /// Total number of cache hits
    public let totalHits: Int

    /// Total number of cache misses
    public let totalMisses: Int

    /// Human-readable description
    public var description: String { get }
}
```

---

## 🔧 Internal API (Module-Internal Use)

These types are `internal` and used within the RichView module but not exposed to consumers.

### 1. HTMLToMarkdownConverter

```swift
/// Converts V2EX HTML to Markdown
internal final class HTMLToMarkdownConverter {

    internal init()

    /// Convert HTML to Markdown
    /// - Parameter html: HTML string
    /// - Returns: Markdown string
    /// - Throws: RenderError if conversion fails
    internal func convert(_ html: String) throws -> String
}
```

### 2. MarkdownRenderer

```swift
/// Renders Markdown to AttributedString
internal final class MarkdownRenderer {

    internal init(configuration: RenderConfiguration)

    /// Render Markdown to AttributedString
    /// - Parameter markdown: Markdown string
    /// - Returns: AttributedString with styling
    /// - Throws: RenderError if rendering fails
    internal func render(_ markdown: String) throws -> AttributedString
}
```

### 3. V2EXMarkupVisitor

```swift
/// Visits swift-markdown AST nodes and builds AttributedString
internal final class V2EXMarkupVisitor: MarkupVisitor {

    internal typealias Result = AttributedString

    internal init(configuration: RenderConfiguration)

    // MarkupVisitor protocol methods...
}
```

### 4. RichTextView

```swift
/// UITextView wrapper for displaying AttributedString
internal struct RichTextView: UIViewRepresentable {

    internal let attributedString: AttributedString
    internal let configuration: RenderConfiguration
    internal var onEvent: ((RichViewEvent) -> Void)?

    internal func makeUIView(context: Context) -> UITextView
    internal func updateUIView(_ uiView: UITextView, context: Context)
    internal func makeCoordinator() -> Coordinator
}
```

### 5. AsyncImageAttachment

```swift
/// NSTextAttachment subclass for async image loading
internal final class AsyncImageAttachment: NSTextAttachment {

    internal init(imageURL: URL, maxHeight: CGFloat)

    internal func loadImage(completion: @escaping (UIImage?) -> Void)
}
```

---

## 📖 Usage Examples

### Basic Usage

```swift
import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.title)
                    .font(.title)

                RichView(htmlContent: post.content) { event in
                    handleEvent(event)
                }
            }
            .padding()
        }
    }

    private func handleEvent(_ event: RichViewEvent) {
        switch event {
        case .linkTapped(let url):
            openURL(url)

        case .imageTapped(let url):
            showImageViewer(url)

        case .mentionTapped(let username):
            navigateToUserProfile(username)

        case .renderCompleted(let metadata):
            print("Rendered in \(metadata.renderTime)ms")

        case .renderFailed(let error):
            print("Render failed: \(error)")
            // In DEBUG, unsupported tags will crash before reaching here

        case .textLongPressed(let text):
            showShareSheet(text)
        }
    }
}
```

### Custom Configuration

```swift
struct CompactPostView: View {
    let post: Post

    var body: some View {
        RichView(htmlContent: post.content)
            .configuration(.compact)
            .onEvent { event in
                // Handle events
            }
    }
}

struct AccessiblePostView: View {
    let post: Post

    var body: some View {
        RichView(htmlContent: post.content)
            .configuration(.largeAccessibility)
            .onEvent { event in
                // Handle events
            }
    }
}
```

### Advanced Stylesheet Configuration

#### GitHub Markdown Style (Built-in)

```swift
struct GitHubStylePostView: View {
    let post: Post

    var body: some View {
        // Use GitHub-flavored Markdown styling (default)
        RichView(htmlContent: post.content)
            .configuration(.default)  // Uses GitHub-like styling
            .onEvent { event in
                handleEvent(event)
            }
    }
}
```

#### Custom Stylesheet

```swift
struct CustomStyledPostView: View {
    let post: Post

    var customStylesheet: RenderStylesheet {
        var stylesheet = RenderStylesheet.default

        // Customize body text
        stylesheet.body.fontSize = 18
        stylesheet.body.lineHeight = 1.6
        stylesheet.body.color = .primary

        // Customize links
        stylesheet.link.color = .purple
        stylesheet.link.underlineStyle = .none

        // Customize code blocks
        stylesheet.code.blockBackgroundColor = Color(hex: "#f6f8fa")
        stylesheet.code.blockBorderWidth = 1
        stylesheet.code.blockBorderColor = Color(hex: "#d0d7de")
        stylesheet.code.highlightTheme = .githubDark

        // Customize @mentions
        stylesheet.mention.color = .blue
        stylesheet.mention.backgroundColor = Color.blue.opacity(0.1)
        stylesheet.mention.fontWeight = .semibold

        // Customize headings
        stylesheet.heading.levels = [
            1: HeadingLevelStyle(fontSize: 28, fontWeight: .bold, marginTop: 24, marginBottom: 16),
            2: HeadingLevelStyle(fontSize: 24, fontWeight: .bold, marginTop: 20, marginBottom: 12),
            3: HeadingLevelStyle(fontSize: 20, fontWeight: .semibold, marginTop: 16, marginBottom: 8)
        ]

        return stylesheet
    }

    var body: some View {
        RichView(htmlContent: post.content)
            .configuration(RenderConfiguration(stylesheet: customStylesheet))
            .onEvent { event in
                handleEvent(event)
            }
    }
}
```

#### Element-Specific Styling

```swift
// Code-heavy content with custom highlighting
var codeStylesheet: RenderStylesheet {
    var stylesheet = RenderStylesheet.default
    stylesheet.code.blockFontSize = 14
    stylesheet.code.highlightTheme = .monokai
    stylesheet.code.blockPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    return stylesheet
}

// Discussion-style with emphasized quotes
var discussionStylesheet: RenderStylesheet {
    var stylesheet = RenderStylesheet.default
    stylesheet.blockquote.backgroundColor = Color.yellow.opacity(0.1)
    stylesheet.blockquote.borderColor = .yellow
    stylesheet.blockquote.borderWidth = 3
    stylesheet.blockquote.padding = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    return stylesheet
}

// Usage
RichView(htmlContent: codeContent)
    .configuration(RenderConfiguration(stylesheet: codeStylesheet))

RichView(htmlContent: discussionContent)
    .configuration(RenderConfiguration(stylesheet: discussionStylesheet))
```

#### Dark Mode Adaptive Styling

```swift
struct AdaptiveStyledView: View {
    let post: Post
    @Environment(\.colorScheme) var colorScheme

    var adaptiveStylesheet: RenderStylesheet {
        var stylesheet = RenderStylesheet.default

        if colorScheme == .dark {
            stylesheet.body.color = Color(hex: "#e6edf3")
            stylesheet.code.blockBackgroundColor = Color(hex: "#161b22")
            stylesheet.code.blockBorderColor = Color(hex: "#30363d")
            stylesheet.code.highlightTheme = .githubDark
            stylesheet.blockquote.textColor = Color(hex: "#8b949e")
            stylesheet.blockquote.borderColor = Color(hex: "#3d444d")
        } else {
            stylesheet.body.color = Color(hex: "#24292f")
            stylesheet.code.blockBackgroundColor = Color(hex: "#f6f8fa")
            stylesheet.code.blockBorderColor = Color(hex: "#d0d7de")
            stylesheet.code.highlightTheme = .github
            stylesheet.blockquote.textColor = Color(hex: "#57606a")
            stylesheet.blockquote.borderColor = Color(hex: "#d0d7de")
        }

        return stylesheet
    }

    var body: some View {
        RichView(htmlContent: post.content)
            .configuration(RenderConfiguration(stylesheet: adaptiveStylesheet))
            .onEvent { event in
                handleEvent(event)
            }
    }
}
```

### Cache Management

```swift
struct SettingsView: View {
    @State private var cacheStats: CacheStatistics?

    var body: some View {
        List {
            Section("Cache") {
                if let stats = cacheStats {
                    Text("Items: \(stats.itemCount)")
                    Text("Size: \(ByteCountFormatter.string(fromByteCount: Int64(stats.sizeBytes), countStyle: .memory))")
                    Text("Hit Rate: \(String(format: "%.1f%%", stats.hitRate * 100))")
                }

                Button("Clear Cache") {
                    RichViewCache.shared.clearAll()
                    updateCacheStats()
                }
            }
        }
        .onAppear {
            updateCacheStats()
        }
    }

    private func updateCacheStats() {
        cacheStats = RichViewCache.shared.statistics()
    }
}
```

### List Performance Optimization

```swift
struct ReplyListView: View {
    let replies: [Reply]

    var body: some View {
        List(replies) { reply in
            ReplyRow(reply: reply)
        }
    }
}

struct ReplyRow: View {
    let reply: Reply

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reply.username)
                    .font(.headline)
                Spacer()
                Text(reply.time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // RichView with caching enabled (default)
            // Automatically reuses cached renders when scrolling
            RichView(htmlContent: reply.content)
                .configuration(.compact)
                .onEvent { event in
                    handleEvent(event, reply: reply)
                }
        }
        .padding(.vertical, 8)
    }
}
```

### Error Handling

```swift
struct RobustPostView: View {
    let post: Post
    @State private var renderError: RenderError?

    var body: some View {
        VStack {
            if let error = renderError {
                // Show error UI
                ErrorView(error: error) {
                    renderError = nil
                }
            } else {
                RichView(htmlContent: post.content)
                    .onEvent { event in
                        switch event {
                        case .renderFailed(let error):
                            // In RELEASE: show error UI
                            // In DEBUG: crash already happened for unsupported tags
                            renderError = error

                        default:
                            handleEvent(event)
                        }
                    }
            }
        }
    }
}

struct ErrorView: View {
    let error: RenderError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("内容渲染失败")
                .font(.headline)

            if let description = error.errorDescription {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("重试") {
                onRetry()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
```

---

## 🧪 Testing Support

### Mock Configuration for Testing

```swift
public extension RenderConfiguration {
    /// Testing configuration with fast rendering
    static let testing: RenderConfiguration = {
        var config = RenderConfiguration.default
        config.enableImages = false
        config.enableCodeHighlighting = false
        config.enableCaching = false
        return config
    }()
}
```

### SwiftUI Preview Examples

```swift
#if DEBUG
public extension RichView {
    /// Create a RichView with sample HTML for previews
    static func preview(
        _ sampleHTML: String = Self.sampleHTML,
        configuration: RenderConfiguration = .default
    ) -> RichView {
        RichView(htmlContent: sampleHTML, configuration: configuration)
    }

    /// Sample HTML snippets for previews
    static let sampleHTML = """
    <p>这是一段<strong>加粗</strong>和<em>斜体</em>的文本。</p>
    <p><a href="/member/username">@username</a> 你好！</p>
    <pre><code class="language-swift">
    func hello() {
        print("Hello, World!")
    }
    </code></pre>
    <p><img src="https://i.v2ex.co/example.jpg" /></p>
    """

    static let codeExample = """
    <p>以下是一个 Swift 代码示例：</p>
    <pre><code class="language-swift">
    struct ContentView: View {
        @State private var text = ""

        var body: some View {
            TextField("输入", text: $text)
                .padding()
        }
    }
    </code></pre>
    """

    static let quoteExample = """
    <blockquote>
    <p>这是一段引用文本，通常用于引用其他人的话。</p>
    </blockquote>
    """

    static let listExample = """
    <h3>无序列表</h3>
    <ul>
        <li>第一项</li>
        <li>第二项</li>
        <li>第三项</li>
    </ul>
    <h3>有序列表</h3>
    <ol>
        <li>步骤一</li>
        <li>步骤二</li>
        <li>步骤三</li>
    </ol>
    """

    static let complexExample = """
    <h2>综合示例</h2>
    <p>这是一段包含 <strong>加粗</strong>、<em>斜体</em> 和 <code>内联代码</code> 的文本。</p>
    <p><a href="/member/livid">@livid</a> 在 V2EX 上分享了一个有趣的想法。</p>
    <blockquote>
    <p>技术的本质是为人服务。</p>
    </blockquote>
    <pre><code class="language-python">
    def fibonacci(n):
        if n <= 1:
            return n
        return fibonacci(n-1) + fibonacci(n-2)
    </code></pre>
    <p><img src="https://i.v2ex.co/example.jpg" alt="示例图片" /></p>
    """
}

// MARK: - Preview Provider

struct RichView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Basic preview
            VStack(alignment: .leading) {
                Text("Basic").font(.headline)
                RichView.preview()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Basic")

            // Code highlighting
            VStack(alignment: .leading) {
                Text("Code Highlighting").font(.headline)
                RichView.preview(RichView.codeExample)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Code")

            // Blockquote
            VStack(alignment: .leading) {
                Text("Blockquote").font(.headline)
                RichView.preview(RichView.quoteExample)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Quote")

            // Lists
            ScrollView {
                RichView.preview(RichView.listExample)
            }
            .previewLayout(.fixed(width: 375, height: 400))
            .previewDisplayName("Lists")

            // Complex
            ScrollView {
                RichView.preview(RichView.complexExample)
            }
            .previewLayout(.fixed(width: 375, height: 600))
            .previewDisplayName("Complex")

            // Dark mode
            ScrollView {
                RichView.preview(RichView.complexExample)
            }
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 375, height: 600))
            .previewDisplayName("Dark Mode")

            // Compact configuration
            ScrollView {
                RichView.preview(
                    RichView.complexExample,
                    configuration: RenderConfiguration(stylesheet: .compact)
                )
            }
            .previewLayout(.fixed(width: 375, height: 600))
            .previewDisplayName("Compact")

            // Custom stylesheet
            ScrollView {
                RichView.preview(
                    RichView.complexExample,
                    configuration: RenderConfiguration(stylesheet: customPreviewStylesheet)
                )
            }
            .previewLayout(.fixed(width: 375, height: 600))
            .previewDisplayName("Custom Style")
        }
    }

    static var customPreviewStylesheet: RenderStylesheet {
        var stylesheet = RenderStylesheet.default
        stylesheet.body.fontSize = 18
        stylesheet.link.color = .purple
        stylesheet.code.highlightTheme = .monokai
        return stylesheet
    }
}
#endif
```

---

## 📊 Performance Considerations

### Caching Strategy

- **Automatic Caching**: Enabled by default for all renders
- **Cache Key**: MD5 hash of HTML content
- **Cache Invalidation**: Automatic LRU eviction
- **Memory Limit**: 50MB by default (configurable)

### Optimization Tips

1. **Reuse Configuration**: Create configuration once, reuse across views
2. **Enable Caching**: Keep `enableCaching = true` for lists
3. **Lazy Loading**: Use LazyVStack for long reply lists
4. **Image Limits**: Set appropriate `maxImageHeight` for your layout

### Performance Metrics

```swift
RichView(htmlContent: content)
    .onEvent { event in
        if case .renderCompleted(let metadata) = event {
            // Track performance
            Analytics.log(
                "render_completed",
                parameters: [
                    "time_ms": metadata.renderTime,
                    "cache_hit": metadata.cacheHit,
                    "rating": metadata.performanceRating.rawValue
                ]
            )
        }
    }
```

---

## 🔐 Thread Safety

- **Main Thread**: All public APIs must be called from main thread
- **Async Rendering**: Internal rendering happens on background threads
- **Cache**: Thread-safe NSCache for concurrent access

---

## ⚠️ Migration Guide

RichView replaces **two** existing implementations in V2er:

### 1. Migration from HtmlView (Topic Content)

**Current Implementation** (`NewsContentView.swift`):
```swift
// WKWebView-based rendering
HtmlView(
    html: contentInfo?.html,
    imgs: contentInfo?.imgs ?? [],
    rendered: $rendered
)
```

**New Implementation**:
```swift
RichView(htmlContent: contentInfo?.html ?? "")
    .onEvent { event in
        switch event {
        case .renderCompleted:
            rendered = true
        case .imageTapped(let url):
            showImageViewer(url)
        default:
            break
        }
    }
```

**Benefits**:
- 10x+ faster rendering (no WebView overhead)
- 70%+ less memory usage
- No height calculation delays
- Native image preview support

---

### 2. Migration from RichText (Reply Content)

**Current Implementation** (`ReplyItemView.swift`):
```swift
// NSAttributedString HTML parser
RichText { info.content }
```

**New Implementation**:
```swift
RichView(htmlContent: info.content)
    .configuration(.compact)  // Smaller fonts for replies
    .onEvent { event in
        handleReplyEvent(event, reply: info)
    }
```

**Benefits**:
- Code syntax highlighting (current implementation doesn't support)
- @mention detection and navigation
- Consistent rendering with topic content
- Better performance with caching

---

### Side-by-Side Comparison

| Feature | HtmlView (Topic) | RichText (Reply) | RichView (New) |
|---------|------------------|------------------|----------------|
| Render Engine | WKWebView | NSAttributedString HTML | AttributedString + Markdown |
| Performance | Slow | Medium | Fast |
| Memory Usage | High | Low | Low |
| Code Highlighting | ❌ | ❌ | ✅ |
| Image Preview | Manual | ❌ | ✅ Built-in |
| @Mention Navigation | Manual | ❌ | ✅ Built-in |
| Height Calculation | Async (delayed) | Sync | Sync |
| Caching | ❌ | ❌ | ✅ Automatic |

---

### Complete Migration Example

**Before** - Two different implementations:

```swift
// Topic content (NewsContentView.swift)
struct NewsContentView: View {
    var contentInfo: FeedDetailInfo.ContentInfo?
    @Binding var rendered: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HtmlView(html: contentInfo?.html, imgs: contentInfo?.imgs ?? [], rendered: $rendered)
            Divider()
        }
    }
}

// Reply content (ReplyItemView.swift)
struct ReplyItemView: View {
    var info: FeedDetailInfo.ReplyInfo.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ... header ...
            RichText { info.content }  // Old Atributika-based
            // ... footer ...
        }
    }
}
```

**After** - Unified RichView:

```swift
// Topic content (NewsContentView.swift)
struct NewsContentView: View {
    var contentInfo: FeedDetailInfo.ContentInfo?
    @Binding var rendered: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            RichView(htmlContent: contentInfo?.html ?? "")
                .configuration(.default)
                .onEvent { event in
                    handleTopicEvent(event)
                }
            Divider()
        }
    }

    private func handleTopicEvent(_ event: RichViewEvent) {
        switch event {
        case .renderCompleted:
            rendered = true
        case .linkTapped(let url):
            openURL(url)
        case .imageTapped(let url):
            showImageViewer(url)
        case .mentionTapped(let username):
            navigateToProfile(username)
        default:
            break
        }
    }
}

// Reply content (ReplyItemView.swift)
struct ReplyItemView: View {
    var info: FeedDetailInfo.ReplyInfo.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ... header ...
            RichView(htmlContent: info.content)
                .configuration(.compact)  // Smaller fonts for replies
                .onEvent { event in
                    handleReplyEvent(event)
                }
            // ... footer ...
        }
    }

    private func handleReplyEvent(_ event: RichViewEvent) {
        switch event {
        case .linkTapped(let url):
            openURL(url)
        case .mentionTapped(let username):
            navigateToProfile(username)
        default:
            break
        }
    }
}
```

---

### Migration Checklist

**Phase 1: Topic Content (NewsContentView)**
- [ ] Replace `HtmlView` with `RichView`
- [ ] Remove `imgs` parameter (images auto-detected)
- [ ] Add event handler for `renderCompleted`
- [ ] Add event handlers for image/link/mention taps
- [ ] Test with various topic types (text, images, code)
- [ ] Verify height calculation works correctly

**Phase 2: Reply Content (ReplyItemView)**
- [ ] Replace `RichText` with `RichView`
- [ ] Use `.compact` configuration
- [ ] Add event handlers for interactions
- [ ] Test with reply list scrolling performance
- [ ] Verify cache hit rate in lists

**Phase 3: Feature Flag**
- [ ] Add `useRichView` feature flag
- [ ] Implement A/B testing logic
- [ ] Monitor performance metrics
- [ ] Gradual rollout (10% → 50% → 100%)

**Phase 4: Cleanup**
- [ ] Remove `HtmlView.swift` after full rollout
- [ ] Remove `RichText.swift` (old Atributika version)
- [ ] Remove Atributika dependency if no longer used
- [ ] Update related documentation

---

## 📝 API Stability

- **Stable APIs**: `RichView`, `RenderConfiguration`, `RichViewEvent`
- **Evolving APIs**: `RenderMetadata`, `RichViewCache`
- **Internal APIs**: Subject to change without notice

---

*Last Updated: 2025-01-19*
*Version: 1.0.0*
