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

    // MARK: - Typography

    /// Base font size for body text (default: 16)
    public var fontSize: CGFloat

    /// Line spacing between lines (default: 6)
    public var lineSpacing: CGFloat

    /// Spacing between paragraphs (default: 12)
    public var paragraphSpacing: CGFloat

    /// Font family (default: system)
    public var fontFamily: String?

    // MARK: - Colors

    /// Text color (default: .label)
    public var textColor: Color

    /// Link color (default: .systemBlue)
    public var linkColor: Color

    /// Code background color (default: .systemGray6)
    public var codeBackgroundColor: Color

    /// Quote border color (default: .systemGray4)
    public var quoteBorderColor: Color

    // MARK: - Behavior

    /// Enable image loading (default: true)
    public var enableImages: Bool

    /// Enable code syntax highlighting (default: true)
    public var enableCodeHighlighting: Bool

    /// Enable text selection (default: true)
    public var enableTextSelection: Bool

    /// Maximum image height (default: 300)
    public var maxImageHeight: CGFloat

    /// Allow WebView degradation for complex content (default: true)
    public var allowDegradation: Bool

    // MARK: - Performance

    /// Enable render caching (default: true)
    public var enableCaching: Bool

    /// Cache size limit in MB (default: 50)
    public var cacheSizeLimit: Int

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
        fontSize: CGFloat = 16,
        lineSpacing: CGFloat = 6,
        paragraphSpacing: CGFloat = 12,
        fontFamily: String? = nil,
        textColor: Color = .label,
        linkColor: Color = .systemBlue,
        codeBackgroundColor: Color = .systemGray6,
        quoteBorderColor: Color = .systemGray4,
        enableImages: Bool = true,
        enableCodeHighlighting: Bool = true,
        enableTextSelection: Bool = true,
        maxImageHeight: CGFloat = 300,
        allowDegradation: Bool = true,
        enableCaching: Bool = true,
        cacheSizeLimit: Int = 50
    )
}
```

---

### 3. RichViewEvent

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
    case renderFailed(RenderError)

    /// WebView degradation was triggered
    /// - Parameter reason: Why degradation happened
    case degradedToWebView(DegradationReason)
}

/// Reasons for falling back to WebView
public enum DegradationReason: String, Equatable {
    /// HTML content exceeds size limit
    case contentTooLarge

    /// Unsupported HTML tags detected
    case unsupportedTags

    /// Conversion to Markdown failed
    case conversionError

    /// Rendering threw an error
    case renderError

    /// User manually requested WebView
    case userRequested
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
public enum RenderError: Error, LocalizedError {

    /// HTML parsing failed
    case htmlParsingFailed(String)

    /// Markdown conversion failed
    case markdownConversionFailed(String)

    /// AttributedString rendering failed
    case renderingFailed(String)

    /// Image loading failed
    case imageLoadFailed(URL, Error)

    /// Invalid configuration
    case invalidConfiguration(String)

    /// Content size exceeds limit
    case contentTooLarge(Int)

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

        case .degradedToWebView(let reason):
            print("Degraded to WebView: \(reason)")

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

### Advanced Configuration

```swift
struct CustomStyledPostView: View {
    let post: Post

    var customConfig: RenderConfiguration {
        var config = RenderConfiguration.default
        config.fontSize = 18
        config.lineSpacing = 8
        config.linkColor = .purple
        config.enableCodeHighlighting = false
        config.maxImageHeight = 400
        return config
    }

    var body: some View {
        RichView(htmlContent: post.content)
            .configuration(customConfig)
            .onEvent { event in
                // Handle events
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
    @State private var usedWebView = false

    var body: some View {
        VStack {
            if let error = renderError {
                ErrorView(error: error) {
                    renderError = nil
                }
            } else {
                RichView(htmlContent: post.content)
                    .onEvent { event in
                        switch event {
                        case .renderFailed(let error):
                            renderError = error

                        case .degradedToWebView(let reason):
                            usedWebView = true
                            showToast("使用备用渲染方式: \(reason.rawValue)")

                        default:
                            handleEvent(event)
                        }
                    }
            }

            if usedWebView {
                Text("内容使用备用渲染方式显示")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
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

### Preview Helpers

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

    /// Sample HTML for previews
    static let sampleHTML = """
    <p>这是一段<strong>加粗</strong>和<em>斜体</em>的文本。</p>
    <p><a href="/member/username">@username</a> 你好！</p>
    <pre><code class="language-swift">
    func hello() {
        print("Hello, World!")
    }
    </code></pre>
    <p><img src="https://example.com/image.jpg" /></p>
    """
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

## ⚠️ Migration from HtmlView

### Before (WebView-based)

```swift
HtmlView(
    html: post.content,
    imgs: post.images,
    rendered: $rendered
)
```

### After (RichView)

```swift
RichView(htmlContent: post.content)
    .onEvent { event in
        switch event {
        case .renderCompleted:
            rendered = true
        default:
            break
        }
    }
```

---

## 📝 API Stability

- **Stable APIs**: `RichView`, `RenderConfiguration`, `RichViewEvent`
- **Evolving APIs**: `RenderMetadata`, `RichViewCache`
- **Internal APIs**: Subject to change without notice

---

*Last Updated: 2025-01-19*
*Version: 1.0.0*
