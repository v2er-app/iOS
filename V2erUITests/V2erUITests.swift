//
//  V2erUITests.swift
//  V2erUITests
//
//  Created by Seth on 2020/5/23.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import XCTest

class V2erUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testFeedNavigationStaysOpen() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for feed to load
        sleep(6)

        // Find a feed item by looking for text that says "评论" (comment count)
        let commentLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '评论'"))
        guard commentLabels.count > 0 else {
            XCTFail("No feed items found (no comment labels)")
            return
        }

        // Tap on the first comment label's parent area
        let firstCommentLabel = commentLabels.element(boundBy: 0)
        XCTAssertTrue(firstCommentLabel.waitForExistence(timeout: 10), "Comment label should exist")
        firstCommentLabel.tap()

        // Wait for navigation animation
        sleep(3)

        // Verify we're on detail page - look for "话题" text or "发表回复" placeholder
        let topicLabel = app.staticTexts["话题"]
        let replyPlaceholder = app.textViews.firstMatch

        let onDetailPage = topicLabel.exists || replyPlaceholder.exists

        XCTAssertTrue(onDetailPage, "Should be on detail page after navigation")

        // Wait longer to verify page stays open (the original bug was page dismissing)
        sleep(3)

        // Verify still on detail page
        let stillOnDetail = topicLabel.exists || replyPlaceholder.exists
        XCTAssertTrue(stillOnDetail, "Detail page should remain open after 3 seconds")

        // Leave app open for visual inspection
        sleep(10)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
