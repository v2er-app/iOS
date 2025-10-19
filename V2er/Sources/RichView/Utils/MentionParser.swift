//
//  MentionParser.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation

/// Parser for @mention detection in text
public class MentionParser {

    /// Regex pattern for @mentions
    /// Matches: @username, @user_name, @user123
    /// Does not match: email@example.com, test@
    private static let mentionPattern = #"(?<![a-zA-Z0-9_])@([a-zA-Z0-9_]+)(?![a-zA-Z0-9_@])"#

    /// Detect all @mentions in text
    public static func findMentions(in text: String) -> [Mention] {
        guard let regex = try? NSRegularExpression(pattern: mentionPattern, options: []) else {
            return []
        }

        let nsString = text as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: text, options: [], range: range)

        return matches.compactMap { match -> Mention? in
            guard match.numberOfRanges >= 2 else { return nil }

            let fullRange = match.range(at: 0)
            let usernameRange = match.range(at: 1)

            guard let fullStringRange = Range(fullRange, in: text),
                  let usernameStringRange = Range(usernameRange, in: text) else {
                return nil
            }

            let fullText = String(text[fullStringRange])
            let username = String(text[usernameStringRange])

            return Mention(
                fullText: fullText,
                username: username,
                range: fullRange
            )
        }
    }

    /// Check if text at position is part of a mention
    public static func isMention(at position: Int, in text: String) -> Bool {
        let mentions = findMentions(in: text)
        return mentions.contains { mention in
            NSLocationInRange(position, mention.range)
        }
    }

    /// Extract username from @mention text
    public static func extractUsername(from mentionText: String) -> String? {
        let trimmed = mentionText.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("@") else { return nil }

        let username = String(trimmed.dropFirst())
        guard !username.isEmpty else { return nil }

        // Validate username format (alphanumeric and underscore only)
        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        guard username.unicodeScalars.allSatisfy({ validCharacters.contains($0) }) else {
            return nil
        }

        return username
    }

    /// Check if text looks like an email (to avoid false positives)
    public static func isEmail(_ text: String) -> Bool {
        let emailPattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        guard let regex = try? NSRegularExpression(pattern: emailPattern, options: []) else {
            return false
        }

        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    /// Replace @mentions in text with custom handler
    public static func replaceMentions(
        in text: String,
        with replacement: (Mention) -> String
    ) -> String {
        let mentions = findMentions(in: text)

        var result = text
        // Process in reverse order to maintain correct indices
        for mention in mentions.reversed() {
            guard let range = Range(mention.range, in: result) else { continue }
            let replacementText = replacement(mention)
            result.replaceSubrange(range, with: replacementText)
        }

        return result
    }
}

// MARK: - Mention Model

/// Represents a detected @mention
public struct Mention: Equatable {
    /// Full text including @ symbol (e.g., "@username")
    public let fullText: String

    /// Username without @ symbol (e.g., "username")
    public let username: String

    /// Range in original text
    public let range: NSRange

    /// Create V2EX profile URL for this mention
    public var profileURL: URL? {
        URL(string: "https://www.v2ex.com/member/\(username)")
    }
}

// MARK: - Extensions

extension MentionParser {
    /// Common V2EX username validation
    public static func isValidV2EXUsername(_ username: String) -> Bool {
        // V2EX usernames: alphanumeric, underscore, 3-20 characters
        guard username.count >= 3, username.count <= 20 else {
            return false
        }

        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return username.unicodeScalars.allSatisfy({ validCharacters.contains($0) })
    }
}