//
//  RichViewCacheTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//

import XCTest
@testable import V2er

@available(iOS 15.0, *)
class RichViewCacheTests: XCTestCase {

    var cache: RichViewCache!

    override func setUp() {
        super.setUp()
        cache = RichViewCache.shared
        cache.clearAll()
    }

    override func tearDown() {
        cache.clearAll()
        super.tearDown()
    }

    // MARK: - Markdown Cache Tests

    func testMarkdownCacheHit() {
        let html = "<p>Hello World</p>"
        let markdown = "Hello World"

        // First access - miss
        XCTAssertNil(cache.getMarkdown(forHTML: html))

        // Set markdown
        cache.setMarkdown(markdown, forHTML: html)

        // Second access - hit
        let retrieved = cache.getMarkdown(forHTML: html)
        XCTAssertEqual(retrieved, markdown)
    }

    func testMarkdownCacheMiss() {
        let html = "<p>Hello World</p>"

        let retrieved = cache.getMarkdown(forHTML: html)
        XCTAssertNil(retrieved)
    }

    func testMarkdownCacheWithDifferentHTML() {
        let html1 = "<p>Hello</p>"
        let html2 = "<p>World</p>"
        let markdown1 = "Hello"
        let markdown2 = "World"

        cache.setMarkdown(markdown1, forHTML: html1)
        cache.setMarkdown(markdown2, forHTML: html2)

        XCTAssertEqual(cache.getMarkdown(forHTML: html1), markdown1)
        XCTAssertEqual(cache.getMarkdown(forHTML: html2), markdown2)
    }

    // MARK: - AttributedString Cache Tests

    func testAttributedStringCacheHit() {
        let markdown = "**Bold** text"
        let attributed = AttributedString("Bold text")

        // First access - miss
        XCTAssertNil(cache.getAttributedString(forMarkdown: markdown))

        // Set attributed string
        cache.setAttributedString(attributed, forMarkdown: markdown)

        // Second access - hit
        let retrieved = cache.getAttributedString(forMarkdown: markdown)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.characters.count, attributed.characters.count)
    }

    func testAttributedStringCacheMiss() {
        let markdown = "Some text"

        let retrieved = cache.getAttributedString(forMarkdown: markdown)
        XCTAssertNil(retrieved)
    }

    // MARK: - Content Elements Cache Tests

    func testContentElementsCacheHit() {
        let html = "<p>Hello</p>"
        let elements = [ContentElement(type: .heading(text: "Hello", level: 1))]

        // First access - miss
        XCTAssertNil(cache.getContentElements(forHTML: html))

        // Set elements
        cache.setContentElements(elements, forHTML: html)

        // Second access - hit
        let retrieved = cache.getContentElements(forHTML: html)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, elements.count)
    }

    func testContentElementsCacheMiss() {
        let html = "<p>Hello</p>"

        let retrieved = cache.getContentElements(forHTML: html)
        XCTAssertNil(retrieved)
    }

    // MARK: - Cache Statistics Tests

    func testCacheStatisticsInitial() {
        let stats = cache.getStatistics()

        XCTAssertEqual(stats.markdownHits, 0)
        XCTAssertEqual(stats.markdownMisses, 0)
        XCTAssertEqual(stats.attributedStringHits, 0)
        XCTAssertEqual(stats.attributedStringMisses, 0)
        XCTAssertEqual(stats.totalHits, 0)
        XCTAssertEqual(stats.totalMisses, 0)
        XCTAssertEqual(stats.hitRate, 0.0)
    }

    func testCacheStatisticsAfterHits() {
        let html = "<p>Test</p>"
        let markdown = "Test"

        // Cause 2 misses
        _ = cache.getMarkdown(forHTML: html)
        _ = cache.getMarkdown(forHTML: html)

        // Set and cause 3 hits
        cache.setMarkdown(markdown, forHTML: html)
        _ = cache.getMarkdown(forHTML: html)
        _ = cache.getMarkdown(forHTML: html)
        _ = cache.getMarkdown(forHTML: html)

        let stats = cache.getStatistics()
        XCTAssertEqual(stats.markdownHits, 3)
        XCTAssertEqual(stats.markdownMisses, 2)
        XCTAssertEqual(stats.totalHits, 3)
        XCTAssertEqual(stats.totalMisses, 2)
        XCTAssertEqual(stats.hitRate, 0.6, accuracy: 0.01)
    }

    func testCacheStatisticsHitRates() {
        let html = "<p>Test</p>"
        let markdown = "Test"
        let attributed = AttributedString("Test")

        // Markdown: 1 miss, 2 hits
        _ = cache.getMarkdown(forHTML: html)
        cache.setMarkdown(markdown, forHTML: html)
        _ = cache.getMarkdown(forHTML: html)
        _ = cache.getMarkdown(forHTML: html)

        // AttributedString: 1 miss, 1 hit
        _ = cache.getAttributedString(forMarkdown: markdown)
        cache.setAttributedString(attributed, forMarkdown: markdown)
        _ = cache.getAttributedString(forMarkdown: markdown)

        let stats = cache.getStatistics()
        XCTAssertEqual(stats.markdownHitRate, 2.0/3.0, accuracy: 0.01)
        XCTAssertEqual(stats.attributedStringHitRate, 0.5, accuracy: 0.01)
    }

    // MARK: - Cache Clear Tests

    func testClearMarkdownCache() {
        let html = "<p>Test</p>"
        let markdown = "Test"

        cache.setMarkdown(markdown, forHTML: html)
        XCTAssertNotNil(cache.getMarkdown(forHTML: html))

        cache.clearMarkdownCache()
        XCTAssertNil(cache.getMarkdown(forHTML: html))
    }

    func testClearAttributedStringCache() {
        let markdown = "Test"
        let attributed = AttributedString("Test")

        cache.setAttributedString(attributed, forMarkdown: markdown)
        XCTAssertNotNil(cache.getAttributedString(forMarkdown: markdown))

        cache.clearAttributedStringCache()
        XCTAssertNil(cache.getAttributedString(forMarkdown: markdown))
    }

    func testClearContentElementsCache() {
        let html = "<p>Test</p>"
        let elements = [ContentElement(type: .heading(text: "Test", level: 1))]

        cache.setContentElements(elements, forHTML: html)
        XCTAssertNotNil(cache.getContentElements(forHTML: html))

        cache.clearContentElementsCache()
        XCTAssertNil(cache.getContentElements(forHTML: html))
    }

    func testClearAllCaches() {
        let html = "<p>Test</p>"
        let markdown = "Test"
        let attributed = AttributedString("Test")
        let elements = [ContentElement(type: .heading(text: "Test", level: 1))]

        cache.setMarkdown(markdown, forHTML: html)
        cache.setAttributedString(attributed, forMarkdown: markdown)
        cache.setContentElements(elements, forHTML: html)

        XCTAssertNotNil(cache.getMarkdown(forHTML: html))
        XCTAssertNotNil(cache.getAttributedString(forMarkdown: markdown))
        XCTAssertNotNil(cache.getContentElements(forHTML: html))

        cache.clearAll()

        XCTAssertNil(cache.getMarkdown(forHTML: html))
        XCTAssertNil(cache.getAttributedString(forMarkdown: markdown))
        XCTAssertNil(cache.getContentElements(forHTML: html))

        // Statistics should also be reset
        let stats = cache.getStatistics()
        XCTAssertEqual(stats.totalHits, 0)
        XCTAssertEqual(stats.totalMisses, 0)
    }

    // MARK: - Cache Key Tests

    func testSameContentSameCacheKey() {
        let html1 = "<p>Hello World</p>"
        let html2 = "<p>Hello World</p>"
        let markdown = "Hello World"

        cache.setMarkdown(markdown, forHTML: html1)

        // Same content should use same cache key
        let retrieved = cache.getMarkdown(forHTML: html2)
        XCTAssertEqual(retrieved, markdown)
    }

    func testDifferentContentDifferentCacheKey() {
        let html1 = "<p>Hello</p>"
        let html2 = "<p>World</p>"
        let markdown1 = "Hello"

        cache.setMarkdown(markdown1, forHTML: html1)

        // Different content should use different cache key
        let retrieved = cache.getMarkdown(forHTML: html2)
        XCTAssertNil(retrieved)
    }

    // MARK: - Performance Tests

    func testCachePerformanceLargeContent() {
        let largeHTML = String(repeating: "<p>Test paragraph with some content.</p>", count: 100)
        let largeMarkdown = String(repeating: "Test paragraph with some content.\n\n", count: 100)

        // Measure cache set
        measure {
            cache.setMarkdown(largeMarkdown, forHTML: largeHTML)
        }
    }

    func testCachePerformanceRetrieveLargeContent() {
        let largeHTML = String(repeating: "<p>Test paragraph with some content.</p>", count: 100)
        let largeMarkdown = String(repeating: "Test paragraph with some content.\n\n", count: 100)

        cache.setMarkdown(largeMarkdown, forHTML: largeHTML)

        // Measure cache get
        measure {
            _ = cache.getMarkdown(forHTML: largeHTML)
        }
    }

    func testCachePerformanceMultipleEntries() {
        let count = 100

        // Prepare test data
        let testData = (0..<count).map { index in
            (html: "<p>Test \(index)</p>", markdown: "Test \(index)")
        }

        // Measure setting multiple entries
        measure {
            for data in testData {
                cache.setMarkdown(data.markdown, forHTML: data.html)
            }
        }
    }

    func testCachePerformanceHitRate() {
        let testData = (0..<50).map { index in
            (html: "<p>Test \(index)</p>", markdown: "Test \(index)")
        }

        // Set all entries
        for data in testData {
            cache.setMarkdown(data.markdown, forHTML: data.html)
        }

        // Measure retrieval performance
        measure {
            for data in testData {
                _ = cache.getMarkdown(forHTML: data.html)
            }
        }

        // Verify high hit rate
        let stats = cache.getStatistics()
        XCTAssertGreaterThan(stats.markdownHitRate, 0.95)
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentWrites() {
        let expectation = XCTestExpectation(description: "Concurrent writes")
        expectation.expectedFulfillmentCount = 10

        // Write from multiple threads
        for i in 0..<10 {
            DispatchQueue.global().async {
                let html = "<p>Test \(i)</p>"
                let markdown = "Test \(i)"
                self.cache.setMarkdown(markdown, forHTML: html)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testConcurrentReads() {
        let html = "<p>Test</p>"
        let markdown = "Test"

        cache.setMarkdown(markdown, forHTML: html)

        let expectation = XCTestExpectation(description: "Concurrent reads")
        expectation.expectedFulfillmentCount = 100

        // Read from multiple threads
        for _ in 0..<100 {
            DispatchQueue.global().async {
                let retrieved = self.cache.getMarkdown(forHTML: html)
                XCTAssertEqual(retrieved, markdown)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}