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

    // MARK: - Table Tests

    func testBasicTableConversion() throws {
        let html = """
        <table>
            <tr><th>Header 1</th><th>Header 2</th></tr>
            <tr><td>Cell 1</td><td>Cell 2</td></tr>
        </table>
        """
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("| Header 1 | Header 2 |"))
        XCTAssertTrue(markdown.contains("| --- | --- |"))
        XCTAssertTrue(markdown.contains("| Cell 1 | Cell 2 |"))
    }

    func testTableWithTheadTbody() throws {
        let html = """
        <table>
            <thead><tr><th>Name</th><th>Value</th></tr></thead>
            <tbody><tr><td>Item</td><td>100</td></tr></tbody>
        </table>
        """
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("| Name | Value |"))
        XCTAssertTrue(markdown.contains("| Item | 100 |"))
    }

    func testTableWithMultipleRows() throws {
        let html = """
        <table>
            <tr><th>功能模块</th><th>详细说明</th></tr>
            <tr><td>多种格式</td><td>EPUB/MOBI/AZW3</td></tr>
            <tr><td>数据同步</td><td>多端覆盖</td></tr>
        </table>
        """
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("功能模块"))
        XCTAssertTrue(markdown.contains("多种格式"))
        XCTAssertTrue(markdown.contains("数据同步"))
    }

    func testTableWithPipeInContent() throws {
        let html = """
        <table>
            <tr><th>Option</th><th>Description</th></tr>
            <tr><td>A | B</td><td>Choose A or B</td></tr>
        </table>
        """
        let markdown = try converter.convert(html)
        // Pipes should be escaped in cell content
        XCTAssertTrue(markdown.contains("A \\| B"))
    }

    // MARK: - Strikethrough Tests

    func testDelTagConversion() throws {
        let html = "<del>Deleted text</del>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("~~Deleted text~~"))
    }

    func testSTagConversion() throws {
        let html = "<s>Strikethrough text</s>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("~~Strikethrough text~~"))
    }

    func testStrikeTagConversion() throws {
        let html = "<strike>Old strike tag</strike>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("~~Old strike tag~~"))
    }

    // MARK: - Underline Tests

    func testUnderlineTagConversion() throws {
        let html = "<u>Underlined text</u>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("<u>Underlined text</u>"))
    }

    func testInsTagConversion() throws {
        let html = "<ins>Inserted text</ins>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("<u>Inserted text</u>"))
    }

    // MARK: - Superscript/Subscript Tests

    func testSuperscriptConversion() throws {
        let html = "x<sup>2</sup>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("<sup>2</sup>"))
    }

    func testSubscriptConversion() throws {
        let html = "H<sub>2</sub>O"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("<sub>2</sub>"))
    }

    // MARK: - Mark/Highlight Tests

    func testMarkTagConversion() throws {
        let html = "<mark>Highlighted text</mark>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("==Highlighted text=="))
    }

    // MARK: - Definition List Tests

    func testDefinitionListConversion() throws {
        let html = """
        <dl>
            <dt>Term</dt>
            <dd>Definition of the term</dd>
        </dl>
        """
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("**Term**"))
        XCTAssertTrue(markdown.contains(": Definition of the term"))
    }

    // MARK: - Semantic Element Tests

    func testAbbreviationWithTitle() throws {
        let html = "<abbr title=\"HyperText Markup Language\">HTML</abbr>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("HTML"))
        XCTAssertTrue(markdown.contains("HyperText Markup Language"))
    }

    func testCiteTagConversion() throws {
        let html = "<cite>Book Title</cite>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("*Book Title*"))
    }

    func testKbdTagConversion() throws {
        let html = "Press <kbd>Ctrl</kbd>+<kbd>C</kbd>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("`Ctrl`"))
        XCTAssertTrue(markdown.contains("`C`"))
    }

    func testSampTagConversion() throws {
        let html = "<samp>Error: File not found</samp>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("`Error: File not found`"))
    }

    func testVarTagConversion() throws {
        let html = "The variable <var>x</var> is used"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("*x*"))
    }

    func testFigcaptionConversion() throws {
        let html = """
        <figure>
            <img src="image.png" alt="Image">
            <figcaption>Image caption</figcaption>
        </figure>
        """
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("![Image](image.png)"))
        XCTAssertTrue(markdown.contains("*Image caption*"))
    }

    func testAddressTagConversion() throws {
        let html = "<address>Contact us at example@email.com</address>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("*Contact us at example@email.com*"))
    }

    func testTimeTagConversion() throws {
        let html = "<time datetime=\"2024-01-01\">January 1, 2024</time>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("January 1, 2024"))
    }

    func testSummaryTagConversion() throws {
        let html = """
        <details>
            <summary>Click to expand</summary>
            <p>Hidden content</p>
        </details>
        """
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("**Click to expand**"))
        XCTAssertTrue(markdown.contains("Hidden content"))
    }

    // MARK: - Container Element Tests

    func testArticleContainerProcessing() throws {
        let html = "<article>Article content</article>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Article content"))
    }

    func testSectionContainerProcessing() throws {
        let html = "<section>Section content</section>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Section content"))
    }

    func testNavContainerProcessing() throws {
        let html = "<nav><a href=\"#\">Link</a></nav>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("[Link]"))
    }

    func testHeaderFooterProcessing() throws {
        let html = "<header>Header</header><footer>Footer</footer>"
        let markdown = try converter.convert(html)
        XCTAssertTrue(markdown.contains("Header"))
        XCTAssertTrue(markdown.contains("Footer"))
    }

    // MARK: - Performance Tests

    func testPerformanceLargeHTML() throws {
        let repeatedHTML = String(repeating: "<p>This is a test paragraph with <strong>bold</strong> text.</p>", count: 100)

        measure {
            _ = try? converter.convert(repeatedHTML)
        }
    }

    func testPerformanceComplexTable() throws {
        var tableHTML = "<table><tr><th>Header 1</th><th>Header 2</th><th>Header 3</th></tr>"
        for i in 1...50 {
            tableHTML += "<tr><td>Row \(i) Col 1</td><td>Row \(i) Col 2</td><td>Row \(i) Col 3</td></tr>"
        }
        tableHTML += "</table>"

        measure {
            _ = try? converter.convert(tableHTML)
        }
    }
}