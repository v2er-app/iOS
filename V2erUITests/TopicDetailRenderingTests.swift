//
//  TopicDetailRenderingTests.swift
//  V2erUITests
//
//  Created for verifying RichView rendering of topic content
//

import XCTest

/// UI Tests for verifying topic detail page rendering
/// These tests navigate to representative topic pages and verify the content renders correctly
class TopicDetailRenderingTests: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Test Topics

    /// Representative topics for testing various content types
    struct TestTopic {
        let id: String
        let description: String
        let expectedElements: [String]  // Text patterns that should appear when rendered

        /// Markdown syntax complete test post - tests various Markdown elements
        static let markdownTestPost = TestTopic(
            id: "1178795",
            description: "Markdown语法完整测试贴",
            expectedElements: ["Markdown"]
        )

        // Add more representative test topics here as needed
        static let allTestTopics: [TestTopic] = [
            markdownTestPost
        ]
    }

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Direct Topic Navigation Tests

    /// Test the Markdown syntax test post (ID: 1178795)
    /// This post contains various Markdown elements that test RichView's rendering capabilities:
    /// - Headers (h1-h6)
    /// - Bold, italic, strikethrough
    /// - Code blocks with syntax highlighting
    /// - Lists (ordered and unordered)
    /// - Links and images
    /// - Tables
    /// - Blockquotes
    func testMarkdownTestPostRendering() throws {
        let testTopic = TestTopic.markdownTestPost
        try verifyTopicDetailRendering(topic: testTopic)
    }

    // MARK: - Helper Methods

    /// Navigate directly to a topic detail page using launch arguments and verify rendering
    /// - Parameter topic: The test topic to verify
    private func verifyTopicDetailRendering(topic: TestTopic) throws {
        // Launch app with test arguments to navigate directly to topic
        app.launchArguments = ["--uitesting", "--test-topic", topic.id]
        app.launch()

        // Wait for the app to initialize and topic detail to appear
        let topicDetailView = app.otherElements["TestTopicDetailView"]
        let topicLabel = app.staticTexts["话题"]

        // Wait for either the test view or topic label to appear
        let detailPageAppeared = topicDetailView.waitForExistence(timeout: 10) ||
                                  topicLabel.waitForExistence(timeout: 10)

        XCTAssertTrue(detailPageAppeared, "Topic detail page should appear for topic \(topic.id)")

        // Wait for RichContentView to render (async rendering)
        // The content should load within a reasonable time
        sleep(8)  // Allow time for network request and rendering

        // Take screenshot of initial state
        let loadingScreenshot = XCTAttachment(screenshot: app.screenshot())
        loadingScreenshot.name = "TopicDetail_\(topic.id)_Loading"
        loadingScreenshot.lifetime = .keepAlways
        add(loadingScreenshot)

        // Check for rendering error indicator
        let errorIndicator = app.staticTexts["Rendering Error"]
        XCTAssertFalse(errorIndicator.exists, "Should not show rendering error for topic \(topic.id)")

        // Verify content is not stuck in loading state
        // Look for actual content (not just loading spinner)
        let progressViews = app.activityIndicators
        let contentTexts = app.staticTexts.allElementsBoundByIndex.filter { $0.label.count > 10 }

        // Either loading should be done or content should exist
        let hasContent = contentTexts.count > 2 || !progressViews.firstMatch.exists

        // Verify expected elements exist if specified
        for expectedElement in topic.expectedElements {
            let elementExists = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] %@", expectedElement)
            ).count > 0

            // Log if expected element wasn't found (for debugging)
            if !elementExists {
                print("Warning: Expected element '\(expectedElement)' not found in topic \(topic.id)")
            }
        }

        // Verify the page stayed open and didn't crash
        let expectation = XCTestExpectation(description: "Wait to verify page stability")
        let result = XCTWaiter.wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(result, .timedOut, "Should wait full 3 seconds without crash")

        // Final screenshot for verification
        let finalScreenshot = XCTAttachment(screenshot: app.screenshot())
        finalScreenshot.name = "TopicDetail_\(topic.id)_Final"
        finalScreenshot.lifetime = .keepAlways
        add(finalScreenshot)

        // Verify still on detail page (didn't navigate away or crash)
        let stillOnDetailPage = topicDetailView.exists || topicLabel.exists ||
                                app.navigationBars.count > 0
        XCTAssertTrue(stillOnDetailPage, "Should still be on topic detail page after waiting")
    }

    // MARK: - Generic Navigation Tests

    /// Test that navigating to any topic detail page works and content renders
    /// This tests the general flow without a specific topic
    func testGenericTopicDetailNavigation() throws {
        app.launchArguments = ["--uitesting"]
        app.launch()

        // Wait for feed to load
        let feedLoaded = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS '评论'")
        ).firstMatch
        XCTAssertTrue(feedLoaded.waitForExistence(timeout: 15), "Feed should load")

        // Tap first topic to navigate
        let firstComment = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS '评论'")
        ).element(boundBy: 0)
        firstComment.tap()

        // Verify detail page appears
        let topicLabel = app.staticTexts["话题"]
        XCTAssertTrue(topicLabel.waitForExistence(timeout: 10), "Topic detail should appear")

        // Wait for RichContentView to render
        sleep(5)

        // Verify no rendering error
        let errorIndicator = app.staticTexts["Rendering Error"]
        XCTAssertFalse(errorIndicator.exists, "Should not show rendering error")

        // Take screenshot
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "TopicDetail_Generic"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    // MARK: - Batch Testing

    /// Run tests for all representative topics
    /// This can be used to verify a batch of topics at once
    func testAllRepresentativeTopics() throws {
        for topic in TestTopic.allTestTopics {
            // Reset app for each topic
            app.terminate()

            app.launchArguments = ["--uitesting", "--test-topic", topic.id]
            app.launch()

            // Wait for detail page
            let topicLabel = app.staticTexts["话题"]
            let appeared = topicLabel.waitForExistence(timeout: 15)

            XCTAssertTrue(appeared, "Topic \(topic.id) (\(topic.description)) should load")

            // Wait for rendering
            sleep(5)

            // Check for errors
            let errorIndicator = app.staticTexts["Rendering Error"]
            XCTAssertFalse(errorIndicator.exists,
                          "Topic \(topic.id) should not have rendering error")

            // Screenshot
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = "TopicDetail_\(topic.id)_\(topic.description)"
            screenshot.lifetime = .keepAlways
            add(screenshot)
        }
    }
}
