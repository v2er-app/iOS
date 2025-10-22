//
//  HTMLToMarkdownConverterTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//

import XCTest
@testable import V2er

class HTMLToMarkdownConverterTests: XCTestCase {

    var converter: HTMLToMarkdownConverter!

    override func setUp() {
        super.setUp()
        converter = HTMLToMarkdownConverter(crashOnUnsupportedTags: false)
    }

    override func tearDown() {
        converter = nil
        super.tearDown()
    }

    // MARK: - Basic Tag Tests

    func testParagraphConversion() throws {
        let html = "<p>This is a paragraph.</p>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("This is a paragraph."))
    }

    func testLineBreakConversion() throws {
        let html = "Line 1<br>Line 2"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Line 1  \nLine 2"))
    }

    func testStrongTagConversion() throws {
        let html = "<strong>Bold text</strong>"
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown.trimmingCharacters(in: .whitespacesAndNewlines), "**Bold text**")
    }

    func testBoldTagConversion() throws {
        let html = "<b>Bold text</b>"
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown.trimmingCharacters(in: .whitespacesAndNewlines), "**Bold text**")
    }

    func testEmphasisTagConversion() throws {
        let html = "<em>Italic text</em>"
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown.trimmingCharacters(in: .whitespacesAndNewlines), "*Italic text*")
    }

    func testItalicTagConversion() throws {
        let html = "<i>Italic text</i>"
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown.trimmingCharacters(in: .whitespacesAndNewlines), "*Italic text*")
    }

    func testLinkConversion() throws {
        let html = "<a href=\"https://www.v2ex.com\">V2EX</a>"
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown.trimmingCharacters(in: .whitespacesAndNewlines), "[V2EX](https://www.v2ex.com)")
    }

    func testInlineCodeConversion() throws {
        let html = "Use <code>print()</code> to output"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("`print()`"))
    }

    func testCodeBlockConversion() throws {
        let html = "<pre><code>func test() {\n    return true\n}</code></pre>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("```"))
        XCTAssertTrue(markdown.contains("func test()"))
    }

    // MARK: - V2EX URL Fixing Tests

    func testProtocolRelativeURLFix() throws {
        let html = "<a href=\"//www.v2ex.com/t/123\">Link</a>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("https://www.v2ex.com"))
    }

    func testRelativeURLFix() throws {
        let html = "<a href=\"/t/123\">Topic</a>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("https://www.v2ex.com/t/123"))
    }

    func testImageProtocolRelativeURLFix() throws {
        let html = "<img src=\"//cdn.v2ex.com/image.png\" alt=\"Image\">"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("https://cdn.v2ex.com"))
    }

    // MARK: - Advanced Tag Tests

    func testBlockquoteConversion() throws {
        let html = "<blockquote>This is a quote</blockquote>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("> This is a quote"))
    }

    func testUnorderedListConversion() throws {
        let html = "<ul><li>Item 1</li><li>Item 2</li></ul>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("- Item 1"))
        XCTAssertTrue(markdown.contains("- Item 2"))
    }

    func testOrderedListConversion() throws {
        let html = "<ol><li>First</li><li>Second</li></ol>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("1. First"))
        XCTAssertTrue(markdown.contains("2. Second"))
    }

    func testHeading1Conversion() throws {
        let html = "<h1>Title</h1>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("# Title"))
    }

    func testHeading2Conversion() throws {
        let html = "<h2>Subtitle</h2>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("## Subtitle"))
    }

    func testImageConversion() throws {
        let html = "<img src=\"https://example.com/image.png\" alt=\"Description\">"
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown.trimmingCharacters(in: .whitespacesAndNewlines),
                      "![Description](https://example.com/image.png)")
    }

    func testHorizontalRuleConversion() throws {
        let html = "<hr>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("---"))
    }

    // MARK: - Complex Content Tests

    func testMixedFormattingConversion() throws {
        let html = "<p>This has <strong>bold</strong> and <em>italic</em> text.</p>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("**bold**"))
        XCTAssertTrue(markdown.contains("*italic*"))
    }

    func testNestedElementsConversion() throws {
        let html = "<p>Check <a href=\"https://example.com\"><strong>this link</strong></a></p>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("[**this link**](https://example.com)"))
    }

    func testMultipleParagraphsConversion() throws {
        let html = "<p>First paragraph</p><p>Second paragraph</p>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("First paragraph"))
        XCTAssertTrue(markdown.contains("Second paragraph"))
        // Check for paragraph separation
        let lines = markdown.components(separatedBy: "\n")
        XCTAssertTrue(lines.count > 2)
    }

    // MARK: - Unsupported Tag Tests

    func testUnsupportedTagWithCrashDisabled() throws {
        converter = HTMLToMarkdownConverter(crashOnUnsupportedTags: false)
        let html = "<video>Video content</video>"

        XCTAssertThrowsError(try converter.convert(html)) { error in
            guard let renderError = error as? RenderError else {
                XCTFail("Expected RenderError")
                return
            }

            switch renderError {
            case .unsupportedTag(let tag, _):
                XCTAssertEqual(tag, "video")
            default:
                XCTFail("Expected unsupportedTag error")
            }
        }
    }

    func testDivContainerProcessing() throws {
        let html = "<div>Content in div</div>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Content in div"))
    }

    func testSpanContainerProcessing() throws {
        let html = "<span>Content in span</span>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Content in span"))
    }

    // MARK: - Edge Cases

    func testEmptyHTML() throws {
        let html = ""
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown, "")
    }

    func testWhitespaceOnlyHTML() throws {
        let html = "   \n\t   "
        let markdown = try converter.convert(html)
        XCTAssertEqual(markdown, "")
    }

    func testMalformedHTML() throws {
        let html = "<p>Unclosed paragraph"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Unclosed paragraph"))
    }

    func testSpecialCharacterEscaping() throws {
        // Test that special Markdown characters are escaped
        let html = "Text with * and _ and #"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("\\*"))
        XCTAssertTrue(markdown.contains("\\_"))
        XCTAssertTrue(markdown.contains("\\#"))
    }

    // MARK: - Performance Tests

    func testPerformanceLargeHTML() throws {
        let repeatedHTML = String(repeating: "<p>This is a test paragraph with <strong>bold</strong> text.</p>", count: 100)

        measure {
            _ = try? converter.convert(repeatedHTML)
        }
    }
}