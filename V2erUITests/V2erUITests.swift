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

        // Wait for feed to load by waiting for the first comment label to appear
        let commentLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '评论'"))
        let firstCommentLabel = commentLabels.element(boundBy: 0)
        XCTAssertTrue(firstCommentLabel.waitForExistence(timeout: 15), "Feed should load and show at least one comment label")

        // Tap on the first comment label's parent area
        firstCommentLabel.tap()

        // Wait for navigation animation by waiting for detail page element to appear
        let topicLabel = app.staticTexts["话题"]
        let replyPlaceholder = app.textViews.firstMatch
        let appeared = topicLabel.waitForExistence(timeout: 5) || replyPlaceholder.waitForExistence(timeout: 5)
        XCTAssertTrue(appeared, "Detail page did not appear after tapping comment label")

        // Wait to verify page stays open (the original bug was page dismissing immediately)
        let expectation = XCTestExpectation(description: "Wait 3 seconds to verify detail page stays open")
        let result = XCTWaiter.wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(result, .timedOut, "Expected to wait full 3 seconds")

        // Verify still on detail page
        let stillOnDetail = topicLabel.exists || replyPlaceholder.exists
        XCTAssertTrue(stillOnDetail, "Detail page should remain open after 3 seconds")
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
