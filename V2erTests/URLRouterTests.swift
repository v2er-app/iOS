//
//  URLRouterTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import XCTest
@testable import V2er

final class URLRouterTests: XCTestCase {

    // MARK: - Topic URL Tests

    func testTopicURL_Full() {
        let result = URLRouter.parse("https://www.v2ex.com/t/123456")
        if case .topic(let id) = result {
            XCTAssertEqual(id, "123456")
        } else {
            XCTFail("Expected topic result, got \(result)")
        }
    }

    func testTopicURL_WithFragment() {
        let result = URLRouter.parse("https://www.v2ex.com/t/123456#reply789")
        if case .topic(let id) = result {
            XCTAssertEqual(id, "123456")
        } else {
            XCTFail("Expected topic result, got \(result)")
        }
    }

    func testTopicURL_Relative() {
        let result = URLRouter.parse("/t/123456")
        if case .topic(let id) = result {
            XCTAssertEqual(id, "123456")
        } else {
            XCTFail("Expected topic result, got \(result)")
        }
    }

    func testTopicURL_AlternativeHost() {
        let result = URLRouter.parse("https://v2ex.com/t/999888")
        if case .topic(let id) = result {
            XCTAssertEqual(id, "999888")
        } else {
            XCTFail("Expected topic result, got \(result)")
        }
    }

    // MARK: - Node URL Tests

    func testNodeURL_Full() {
        let result = URLRouter.parse("https://www.v2ex.com/go/swift")
        if case .node(let name) = result {
            XCTAssertEqual(name, "swift")
        } else {
            XCTFail("Expected node result, got \(result)")
        }
    }

    func testNodeURL_Relative() {
        let result = URLRouter.parse("/go/programming")
        if case .node(let name) = result {
            XCTAssertEqual(name, "programming")
        } else {
            XCTFail("Expected node result, got \(result)")
        }
    }

    func testNodeURL_WithQueryParams() {
        let result = URLRouter.parse("https://www.v2ex.com/go/swift?p=2")
        if case .node(let name) = result {
            XCTAssertEqual(name, "swift")
        } else {
            XCTFail("Expected node result, got \(result)")
        }
    }

    // MARK: - Member URL Tests

    func testMemberURL_Full() {
        let result = URLRouter.parse("https://www.v2ex.com/member/livid")
        if case .member(let username) = result {
            XCTAssertEqual(username, "livid")
        } else {
            XCTFail("Expected member result, got \(result)")
        }
    }

    func testMemberURL_Relative() {
        let result = URLRouter.parse("/member/testuser")
        if case .member(let username) = result {
            XCTAssertEqual(username, "testuser")
        } else {
            XCTFail("Expected member result, got \(result)")
        }
    }

    // MARK: - External URL Tests

    func testExternalURL_Google() {
        let result = URLRouter.parse("https://www.google.com")
        if case .external(let url) = result {
            XCTAssertEqual(url.host, "www.google.com")
        } else {
            XCTFail("Expected external result, got \(result)")
        }
    }

    func testExternalURL_GitHub() {
        let result = URLRouter.parse("https://github.com/v2er-app/iOS")
        if case .external(let url) = result {
            XCTAssertTrue(url.absoluteString.contains("github.com"))
        } else {
            XCTFail("Expected external result, got \(result)")
        }
    }

    // MARK: - Webview URL Tests

    func testWebviewURL_About() {
        let result = URLRouter.parse("https://www.v2ex.com/about")
        if case .webview(let url) = result {
            XCTAssertTrue(url.path.contains("about"))
        } else {
            XCTFail("Expected webview result, got \(result)")
        }
    }

    func testWebviewURL_Help() {
        let result = URLRouter.parse("https://www.v2ex.com/help/currency")
        if case .webview = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected webview result, got \(result)")
        }
    }

    // MARK: - Invalid URL Tests

    func testInvalidURL_Empty() {
        let result = URLRouter.parse("")
        if case .invalid = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected invalid result, got \(result)")
        }
    }

    func testInvalidURL_Malformed() {
        let result = URLRouter.parse("ht!tp://invalid url with spaces")
        if case .invalid = result {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected invalid result, got \(result)")
        }
    }

    // MARK: - Navigation Destination Tests

    func testDestination_Topic() {
        let destination = URLRouter.destination(from: "https://www.v2ex.com/t/123456")
        XCTAssertEqual(destination, .feedDetail(id: "123456"))
    }

    func testDestination_Member() {
        let destination = URLRouter.destination(from: "/member/livid")
        XCTAssertEqual(destination, .userDetail(username: "livid"))
    }

    func testDestination_Node() {
        let destination = URLRouter.destination(from: "/go/swift")
        XCTAssertEqual(destination, .tagDetail(name: "swift"))
    }

    func testDestination_External() {
        let destination = URLRouter.destination(from: "https://www.google.com")
        XCTAssertNil(destination)
    }

    // MARK: - Edge Cases

    func testTopicURL_TrailingSlash() {
        let result = URLRouter.parse("https://www.v2ex.com/t/123456/")
        if case .topic(let id) = result {
            XCTAssertEqual(id, "123456")
        } else {
            XCTFail("Expected topic result, got \(result)")
        }
    }

    func testNodeURL_MultipleSegments() {
        // Should only extract the first segment after /go/
        let result = URLRouter.parse("https://www.v2ex.com/go/swift/extra")
        if case .node(let name) = result {
            XCTAssertEqual(name, "swift")
        } else {
            XCTFail("Expected node result, got \(result)")
        }
    }

    func testMemberURL_WithTab() {
        let result = URLRouter.parse("https://www.v2ex.com/member/livid/topics")
        if case .member(let username) = result {
            XCTAssertEqual(username, "livid")
        } else {
            XCTFail("Expected member result, got \(result)")
        }
    }
}
