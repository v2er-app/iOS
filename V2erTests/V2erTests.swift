//
//  V2erTests.swift
//  V2erTests
//
//  Created by Seth on 2020/5/23.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import XCTest
@testable import V2er

class V2erTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testReportLinkHandling() throws {
        // Test that FeedDetailInfo correctly handles empty reportLink
        var feedDetailInfo = FeedDetailInfo()
        
        // When reportLink is set to empty, it should not be nil
        feedDetailInfo.reportLink = .empty
        XCTAssertNotNil(feedDetailInfo.reportLink)
        XCTAssertTrue(feedDetailInfo.reportLink!.isEmpty)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
