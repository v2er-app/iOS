//
//  RenderPerformanceTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//

import XCTest
@testable import V2er

@available(iOS 15.0, *)
class RenderPerformanceTests: XCTestCase {

    var renderActor: RenderActor!

    override func setUp() {
        super.setUp()
        renderActor = RenderActor()
        RichViewCache.shared.clearAll()
    }

    override func tearDown() {
        RichViewCache.shared.clearAll()
        super.tearDown()
    }

    // MARK: - Small Content Benchmarks

    func testPerformanceSmallTextOnly() {
        let html = "<p>This is a simple paragraph with <strong>bold</strong> text.</p>"
        let config = RenderConfiguration.default

        measure {
            let expectation = XCTestExpectation(description: "Render small text")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }

    func testPerformanceSmallWithCode() {
        let html = """
            <p>Here's some code:</p>
            <pre><code>func hello() {
                print("Hello")
            }</code></pre>
            """
        let config = RenderConfiguration.default

        measure {
            let expectation = XCTestExpectation(description: "Render small code")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }

    // MARK: - Medium Content Benchmarks

    func testPerformanceMediumContent() {
        let html = """
            <h2>Title</h2>
            <p>This is a paragraph with <strong>bold</strong> and <em>italic</em>.</p>
            <blockquote>A quote here</blockquote>
            <pre><code>let x = 10
            print(x)</code></pre>
            <ul>
                <li>Item 1</li>
                <li>Item 2</li>
                <li>Item 3</li>
            </ul>
            <p>Thanks @user for the feedback!</p>
            """
        let config = RenderConfiguration.default

        measure {
            let expectation = XCTestExpectation(description: "Render medium content")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 2.0)
        }
    }

    // MARK: - Large Content Benchmarks

    func testPerformanceLargeContent() {
        let html = String(repeating: """
            <h2>Section Title</h2>
            <p>This is a paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
            <pre><code>func example() {
                let value = 100
                return value
            }</code></pre>
            <p>Some more text here with a <a href="https://example.com">link</a>.</p>
            """, count: 10)

        let config = RenderConfiguration.default

        measure {
            let expectation = XCTestExpectation(description: "Render large content")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Cache Performance Tests

    func testPerformanceCacheHit() {
        let html = "<p>Cached content</p>"
        let config = RenderConfiguration.default

        // First render to populate cache
        let expectation1 = XCTestExpectation(description: "First render")
        Task {
            _ = try? await renderActor.render(html: html, configuration: config)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        // Measure cache hit performance
        measure {
            let expectation2 = XCTestExpectation(description: "Cache hit render")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation2.fulfill()
            }

            wait(for: [expectation2], timeout: 1.0)
        }
    }

    func testPerformanceCacheMiss() {
        let config = RenderConfiguration.default

        // Clear cache before each iteration
        measure {
            RichViewCache.shared.clearAll()

            let html = "<p>Uncached content \(UUID().uuidString)</p>"
            let expectation = XCTestExpectation(description: "Cache miss render")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }

    // MARK: - Real-World V2EX Content Tests

    func testPerformanceV2EXTypicalReply() {
        let html = """
            <p>@原作者 说得对，我也遇到了这个问题。</p>
            <p>我的解决方案是使用 <code>RichView</code> 来渲染内容。</p>
            <pre><code>let view = RichView(htmlContent: content)
            view.configuration(.compact)</code></pre>
            <p>效果很不错！</p>
            """
        let config = RenderConfiguration.compact

        measure {
            let expectation = XCTestExpectation(description: "V2EX reply render")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }

    func testPerformanceV2EXTypicalTopic() {
        let html = """
            <h1>如何优化 iOS 应用的渲染性能？</h1>

            <p>最近在开发一个 V2EX 客户端，遇到了渲染性能问题。</p>

            <h2>问题描述</h2>

            <p>使用 <code>WKWebView</code> 渲染 HTML 内容时，性能开销很大：</p>

            <ul>
                <li>渲染时间约 200ms</li>
                <li>内存占用高达 200MB (100 条内容)</li>
                <li>滚动帧率只有 30 FPS</li>
            </ul>

            <h2>解决方案</h2>

            <p>我开发了一个新的渲染组件 <strong>RichView</strong>：</p>

            <pre><code class="language-swift">// 初始化
            let richView = RichView(htmlContent: html)
            richView.configuration(.default)

            // 事件处理
            richView.onLinkTapped { url in
                print("Tapped: \\(url)")
            }</code></pre>

            <h2>性能对比</h2>

            <blockquote>
                RichView 的渲染时间降低到 50ms 以内，内存占用减少到 10MB。
            </blockquote>

            <p>感谢 @Livid 提供的建议！</p>

            <p>项目地址：<a href="https://github.com/example/richview">GitHub</a></p>
            """

        let config = RenderConfiguration.default

        measure {
            let expectation = XCTestExpectation(description: "V2EX topic render")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 2.0)
        }
    }

    // MARK: - Concurrent Rendering Tests

    func testPerformanceConcurrentRendering() {
        let htmlContents = (0..<10).map { index in
            "<p>Content \(index) with <strong>bold</strong> text.</p>"
        }
        let config = RenderConfiguration.default

        measure {
            let expectation = XCTestExpectation(description: "Concurrent rendering")
            expectation.expectedFulfillmentCount = htmlContents.count

            for html in htmlContents {
                Task {
                    _ = try? await renderActor.render(html: html, configuration: config)
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Memory Performance Tests

    func testMemoryPerformanceWithCaching() {
        let htmlContents = (0..<100).map { index in
            "<p>Test content \(index) with some text.</p>"
        }
        let config = RenderConfiguration.default

        measure(metrics: [XCTMemoryMetric()]) {
            let expectation = XCTestExpectation(description: "Memory test")
            expectation.expectedFulfillmentCount = htmlContents.count

            for html in htmlContents {
                Task {
                    _ = try? await renderActor.render(html: html, configuration: config)
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }
    }

    // MARK: - Baseline Comparison Tests

    func testPerformanceBaseline() {
        // This establishes a baseline for simple HTML conversion
        let html = "<p>Simple <strong>text</strong></p>"
        let converter = HTMLToMarkdownConverter(crashOnUnsupportedTags: false)

        measure {
            _ = try? converter.convert(html)
        }
    }

    func testPerformanceBaselineMarkdownRendering() {
        // Baseline for Markdown to AttributedString
        let markdown = "**Bold** and *italic* text with `code`"
        let renderer = MarkdownRenderer(stylesheet: .default)

        measure {
            _ = try? renderer.render(markdown)
        }
    }

    // MARK: - Configuration Impact Tests

    func testPerformanceWithoutCaching() {
        let html = "<p>Content without caching</p>"
        var config = RenderConfiguration.default
        config.enableCaching = false

        measure {
            let expectation = XCTestExpectation(description: "No cache render")

            Task {
                _ = try? await renderActor.render(html: html, configuration: config)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }

    func testPerformanceCompactVsDefault() {
        let html = "<p>Test content</p>"

        // Default configuration
        measure {
            let expectation = XCTestExpectation(description: "Default config")

            Task {
                _ = try? await renderActor.render(html: html, configuration: .default)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }

        // Compact configuration
        measure {
            let expectation = XCTestExpectation(description: "Compact config")

            Task {
                _ = try? await renderActor.render(html: html, configuration: .compact)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }
}