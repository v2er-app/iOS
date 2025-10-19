//
//  MentionParserTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//

import XCTest
@testable import V2er

class MentionParserTests: XCTestCase {

    // MARK: - Basic Detection Tests

    func testSimpleMention() {
        let text = "Hello @username!"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "username")
        XCTAssertEqual(mentions.first?.fullText, "@username")
    }

    func testMultipleMentions() {
        let text = "@alice and @bob are here, also @charlie"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 3)
        XCTAssertEqual(mentions[0].username, "alice")
        XCTAssertEqual(mentions[1].username, "bob")
        XCTAssertEqual(mentions[2].username, "charlie")
    }

    func testMentionWithUnderscore() {
        let text = "Thanks @user_name"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "user_name")
    }

    func testMentionWithNumbers() {
        let text = "Hello @user123"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "user123")
    }

    func testMentionAtStartOfLine() {
        let text = "@username is here"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "username")
    }

    func testMentionAtEndOfLine() {
        let text = "Thanks to @username"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "username")
    }

    // MARK: - Email Exclusion Tests

    func testEmailNotDetected() {
        let text = "Contact me at user@example.com"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 0, "Email should not be detected as mention")
    }

    func testEmailValidation() {
        XCTAssertTrue(MentionParser.isEmail("user@example.com"))
        XCTAssertTrue(MentionParser.isEmail("test.user@domain.co.uk"))
        XCTAssertFalse(MentionParser.isEmail("@username"))
        XCTAssertFalse(MentionParser.isEmail("not-an-email"))
    }

    func testMentionAndEmail() {
        let text = "Email @john at john@example.com"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "john")
    }

    // MARK: - Edge Cases

    func testNoMentions() {
        let text = "Hello world, no mentions here"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 0)
    }

    func testEmptyString() {
        let text = ""
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 0)
    }

    func testOnlyAtSymbol() {
        let text = "@ alone"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 0)
    }

    func testMentionWithSpecialCharactersNotDetected() {
        let text = "@user-name @user.name @user#name"
        let mentions = MentionParser.findMentions(in: text)

        // Hyphens, dots, and # should not be part of mentions
        XCTAssertEqual(mentions.count, 0)
    }

    func testConsecutiveMentions() {
        let text = "@alice@bob"
        let mentions = MentionParser.findMentions(in: text)

        // Should detect alice but not bob (no space)
        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "alice")
    }

    // MARK: - Username Extraction Tests

    func testExtractUsernameValid() {
        XCTAssertEqual(MentionParser.extractUsername(from: "@username"), "username")
        XCTAssertEqual(MentionParser.extractUsername(from: "@user_name"), "user_name")
        XCTAssertEqual(MentionParser.extractUsername(from: "@user123"), "user123")
    }

    func testExtractUsernameInvalid() {
        XCTAssertNil(MentionParser.extractUsername(from: "username"))
        XCTAssertNil(MentionParser.extractUsername(from: "@"))
        XCTAssertNil(MentionParser.extractUsername(from: ""))
        XCTAssertNil(MentionParser.extractUsername(from: "@user-name"))
        XCTAssertNil(MentionParser.extractUsername(from: "@user.name"))
    }

    // MARK: - Position Detection Tests

    func testIsMentionAtPosition() {
        let text = "Hello @username, how are you?"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertTrue(MentionParser.isMention(at: 7, in: text)) // @ position
        XCTAssertTrue(MentionParser.isMention(at: 10, in: text)) // middle of username
        XCTAssertFalse(MentionParser.isMention(at: 0, in: text)) // before mention
        XCTAssertFalse(MentionParser.isMention(at: 20, in: text)) // after mention
    }

    // MARK: - Profile URL Tests

    func testProfileURL() {
        let mention = Mention(
            fullText: "@johndoe",
            username: "johndoe",
            range: NSRange(location: 0, length: 8)
        )

        XCTAssertNotNil(mention.profileURL)
        XCTAssertEqual(mention.profileURL?.absoluteString, "https://www.v2ex.com/member/johndoe")
    }

    // MARK: - V2EX Username Validation Tests

    func testValidV2EXUsernames() {
        XCTAssertTrue(MentionParser.isValidV2EXUsername("abc"))
        XCTAssertTrue(MentionParser.isValidV2EXUsername("user_name"))
        XCTAssertTrue(MentionParser.isValidV2EXUsername("user123"))
        XCTAssertTrue(MentionParser.isValidV2EXUsername("a1b2c3"))
        XCTAssertTrue(MentionParser.isValidV2EXUsername("username12345"))
    }

    func testInvalidV2EXUsernames() {
        XCTAssertFalse(MentionParser.isValidV2EXUsername("ab")) // Too short
        XCTAssertFalse(MentionParser.isValidV2EXUsername("a")) // Too short
        XCTAssertFalse(MentionParser.isValidV2EXUsername("")) // Empty
        XCTAssertFalse(MentionParser.isValidV2EXUsername("verylongusernamethatexceedstwentycharacters")) // Too long
        XCTAssertFalse(MentionParser.isValidV2EXUsername("user-name")) // Invalid character
        XCTAssertFalse(MentionParser.isValidV2EXUsername("user.name")) // Invalid character
        XCTAssertFalse(MentionParser.isValidV2EXUsername("user name")) // Space
    }

    // MARK: - Replace Mentions Tests

    func testReplaceMentions() {
        let text = "Hello @alice and @bob!"
        let replaced = MentionParser.replaceMentions(in: text) { mention in
            "[\(mention.username)]"
        }

        XCTAssertEqual(replaced, "Hello [alice] and [bob]!")
    }

    func testReplaceMentionsWithURL() {
        let text = "Thanks @john"
        let replaced = MentionParser.replaceMentions(in: text) { mention in
            "<a href=\"\(mention.profileURL?.absoluteString ?? "")\">\(mention.fullText)</a>"
        }

        XCTAssertTrue(replaced.contains("https://www.v2ex.com/member/john"))
    }

    // MARK: - Real-World V2EX Content Tests

    func testV2EXStyleMention() {
        let text = "感谢 @Livid 的分享"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 1)
        XCTAssertEqual(mentions.first?.username, "Livid")
    }

    func testMultipleV2EXMentions() {
        let text = "@jack 你好，cc @tom @jerry"
        let mentions = MentionParser.findMentions(in: text)

        XCTAssertEqual(mentions.count, 3)
        XCTAssertEqual(mentions[0].username, "jack")
        XCTAssertEqual(mentions[1].username, "tom")
        XCTAssertEqual(mentions[2].username, "jerry")
    }

    // MARK: - Performance Tests

    func testPerformanceWithManyMentions() {
        let text = String(repeating: "Hello @user1 and @user2 ", count: 100)

        measure {
            _ = MentionParser.findMentions(in: text)
        }
    }

    func testPerformanceLargeText() {
        let text = String(repeating: "This is a long text without mentions. ", count: 1000)

        measure {
            _ = MentionParser.findMentions(in: text)
        }
    }
}