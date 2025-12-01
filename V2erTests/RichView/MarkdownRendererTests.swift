//
//  MarkdownRendererTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//

import XCTest
import SwiftUI
@testable import V2er

@available(iOS 15.0, *)
class MarkdownRendererTests: XCTestCase {

    var renderer: MarkdownRenderer!

    override func setUp() {
        super.setUp()
        renderer = MarkdownRenderer(
            stylesheet: .default,
            enableCodeHighlighting: true
        )
    }

    override func tearDown() {
        renderer = nil
        super.tearDown()
    }

    // MARK: - Plain Text Tests

    func testPlainTextRendering() throws {
        let markdown = "This is plain text"
        let attributed = try renderer.render(markdown)

        XCTAssertEqual(attributed.characters.count, markdown.count + 1) // +1 for newline
        XCTAssertTrue(attributed.description.contains("This is plain text"))
    }

    // MARK: - Text Formatting Tests

    func testBoldTextRendering() throws {
        let markdown = "This is **bold** text"
        let attributed = try renderer.render(markdown)

        // Check that the text contains bold
        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("bold"))
    }

    func testItalicTextRendering() throws {
        let markdown = "This is *italic* text"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("italic"))
    }

    func testInlineCodeRendering() throws {
        let markdown = "Use `print()` function"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("print()"))
    }

    func testLinkRendering() throws {
        let markdown = "Visit [V2EX](https://www.v2ex.com)"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("V2EX"))
    }

    func testMentionRendering() throws {
        let markdown = "Hello @username!"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("@username"))
    }

    // MARK: - Heading Tests

    func testHeading1Rendering() throws {
        let markdown = "# Heading 1"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("Heading 1"))
    }

    func testHeading2Rendering() throws {
        let markdown = "## Heading 2"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("Heading 2"))
    }

    func testMultipleHeadingsRendering() throws {
        let markdown = """
            # H1
            ## H2
            ### H3
            #### H4
            ##### H5
            ###### H6
            """
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("H1"))
        XCTAssertTrue(string.contains("H2"))
        XCTAssertTrue(string.contains("H3"))
        XCTAssertTrue(string.contains("H4"))
        XCTAssertTrue(string.contains("H5"))
        XCTAssertTrue(string.contains("H6"))
    }

    // MARK: - Code Block Tests

    func testCodeBlockRendering() throws {
        let markdown = """
            ```
            func test() {
                print("Hello")
            }
            ```
            """
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("func test()"))
        XCTAssertTrue(string.contains("print"))
    }

    func testCodeBlockWithLanguageRendering() throws {
        let markdown = """
            ```swift
            let x = 10
            ```
            """
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("let x = 10"))
    }

    // MARK: - Blockquote Tests

    func testBlockquoteRendering() throws {
        let markdown = "> This is a quote"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("This is a quote"))
    }

    // MARK: - List Tests

    func testUnorderedListRendering() throws {
        let markdown = """
            - Item 1
            - Item 2
            - Item 3
            """
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("• Item 1"))
        XCTAssertTrue(string.contains("• Item 2"))
        XCTAssertTrue(string.contains("• Item 3"))
    }

    func testOrderedListRendering() throws {
        let markdown = """
            1. First
            2. Second
            3. Third
            """
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("1. First"))
        XCTAssertTrue(string.contains("2. Second"))
        XCTAssertTrue(string.contains("3. Third"))
    }

    // MARK: - HTML Tag Rendering Tests

    func testUnderlineRendering() throws {
        let markdown = "This has <u>underlined</u> text"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("underlined"))
        // The underline should be rendered (no HTML tags in output)
        XCTAssertFalse(string.contains("<u>"))
        XCTAssertFalse(string.contains("</u>"))
    }

    func testSuperscriptRendering() throws {
        let markdown = "x<sup>2</sup> + y<sup>3</sup>"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("x"))
        XCTAssertTrue(string.contains("2"))
        XCTAssertTrue(string.contains("3"))
        // The superscript should be rendered (no HTML tags in output)
        XCTAssertFalse(string.contains("<sup>"))
        XCTAssertFalse(string.contains("</sup>"))
    }

    func testSubscriptRendering() throws {
        let markdown = "H<sub>2</sub>O"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("H"))
        XCTAssertTrue(string.contains("2"))
        XCTAssertTrue(string.contains("O"))
        // The subscript should be rendered (no HTML tags in output)
        XCTAssertFalse(string.contains("<sub>"))
        XCTAssertFalse(string.contains("</sub>"))
    }

    // MARK: - Mixed Content Tests

    func testMixedFormattingRendering() throws {
        let markdown = "Text with **bold**, *italic*, and `code`"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("bold"))
        XCTAssertTrue(string.contains("italic"))
        XCTAssertTrue(string.contains("code"))
    }

    func testComplexDocumentRendering() throws {
        let markdown = """
            # Title

            This is a paragraph with **bold** and *italic* text.

            ## Section

            > A blockquote

            - List item 1
            - List item 2

            ```
            code block
            ```

            Visit [link](https://example.com) and mention @user.
            """

        let attributed = try renderer.render(markdown)
        let string = String(attributed.characters)

        XCTAssertTrue(string.contains("Title"))
        XCTAssertTrue(string.contains("Section"))
        XCTAssertTrue(string.contains("bold"))
        XCTAssertTrue(string.contains("italic"))
        XCTAssertTrue(string.contains("blockquote"))
        XCTAssertTrue(string.contains("List item"))
        XCTAssertTrue(string.contains("code block"))
        XCTAssertTrue(string.contains("link"))
        XCTAssertTrue(string.contains("@user"))
    }

    // MARK: - Stylesheet Tests

    func testCompactStylesheetRendering() throws {
        renderer = MarkdownRenderer(
            stylesheet: .compact,
            enableCodeHighlighting: true
        )

        let markdown = "# Heading\n\nParagraph text"
        let attributed = try renderer.render(markdown)

        // Just verify it renders without error with compact style
        XCTAssertTrue(attributed.characters.count > 0)
    }

    func testCustomStylesheetRendering() throws {
        var customStylesheet = RenderStylesheet.default
        customStylesheet.body.fontSize = 20
        customStylesheet.link.color = .orange

        renderer = MarkdownRenderer(
            stylesheet: customStylesheet,
            enableCodeHighlighting: true
        )

        let markdown = "Text with [link](https://example.com)"
        let attributed = try renderer.render(markdown)

        // Just verify it renders without error with custom style
        XCTAssertTrue(attributed.characters.count > 0)
    }

    // MARK: - Edge Cases

    func testEmptyMarkdownRendering() throws {
        let markdown = ""
        let attributed = try renderer.render(markdown)

        XCTAssertEqual(attributed.characters.count, 0)
    }

    func testWhitespaceOnlyRendering() throws {
        let markdown = "   \n\n   "
        let attributed = try renderer.render(markdown)

        // Should have newlines but minimal content
        XCTAssertTrue(attributed.characters.count <= 3)
    }

    func testHorizontalRuleRendering() throws {
        let markdown = "---"
        let attributed = try renderer.render(markdown)

        let string = String(attributed.characters)
        XCTAssertTrue(string.contains("─")) // Box drawing character
    }

    // MARK: - Performance Tests

    func testPerformanceLargeDocument() throws {
        let repeatedMarkdown = String(
            repeating: "# Heading\n\nThis is a paragraph with **bold** text.\n\n",
            count: 100
        )

        measure {
            _ = try? renderer.render(repeatedMarkdown)
        }
    }

    func testPerformanceMixedContent() throws {
        let complexMarkdown = """
            # Main Title

            This is the introduction with **bold**, *italic*, and `code`.

            ## Section 1

            > Important quote here

            - Item one with [link](https://example.com)
            - Item two with @mention
            - Item three with more content

            ```swift
            func example() {
                let x = 10
                print(x)
            }
            ```

            ### Subsection

            1. First point
            2. Second point
            3. Third point

            Regular paragraph with more text.
            """

        let repeated = String(repeating: complexMarkdown + "\n\n", count: 20)

        measure {
            _ = try? renderer.render(repeated)
        }
    }
}