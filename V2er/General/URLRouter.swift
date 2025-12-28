//
//  URLRouter.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

/// URL Router for handling V2EX internal and external links
/// Similar to Android's UrlInterceptor.java
class URLRouter {

    // MARK: - URL Patterns

    private static let v2exHost = "www.v2ex.com"
    private static let v2exAltHost = "v2ex.com"

    /// Result of URL interception
    enum InterceptResult: Equatable {
        case topic(id: String)           // /t/123456
        case node(name: String)          // /go/swift
        case member(username: String)    // /member/username
        case external(url: URL)          // External URL
        case webview(url: URL)           // Internal URL to open in webview
        case invalid                     // Invalid URL

        /// Whether this result should use native navigation
        var isNativeNavigation: Bool {
            switch self {
            case .topic, .node, .member:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - URL Parsing

    /// Parse and classify URL
    /// - Parameter urlString: URL string to parse
    /// - Returns: InterceptResult indicating how to handle the URL
    static func parse(_ urlString: String) -> InterceptResult {
        guard !urlString.isEmpty else {
            return .invalid
        }

        var fullURL = urlString

        // Handle relative paths
        if urlString.hasPrefix("/") {
            fullURL = "https://\(v2exHost)\(urlString)"
        } else if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            fullURL = "https://\(v2exHost)/\(urlString)"
        }

        guard let url = URL(string: fullURL),
              let host = url.host else {
            return .invalid
        }

        // Check if it's V2EX domain
        let isV2EX = host.contains(v2exHost) || host.contains(v2exAltHost)

        if !isV2EX {
            // External URL - open in Safari or custom tabs
            return .external(url: url)
        }

        // Parse V2EX internal URLs
        let path = url.path

        // Topic: /t/123456 or /t/123456#reply123
        if path.contains("/t/") {
            if let topicId = extractTopicId(from: path) {
                return .topic(id: topicId)
            }
        }

        // Node: /go/swift
        if path.contains("/go/") {
            if let nodeName = extractNodeName(from: path) {
                return .node(name: nodeName)
            }
        }

        // Member: /member/username
        if path.contains("/member/") {
            if let username = extractUsername(from: path) {
                return .member(username: username)
            }
        }

        // Other V2EX URLs - open in webview
        return .webview(url: url)
    }

    // MARK: - Extraction Helpers

    /// Extract topic ID from path like /t/123456 or /t/123456#reply123
    private static func extractTopicId(from path: String) -> String? {
        let pattern = "/t/(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: path, range: NSRange(path.startIndex..., in: path)),
              let range = Range(match.range(at: 1), in: path) else {
            return nil
        }
        return String(path[range])
    }

    /// Extract node name from path like /go/swift
    private static func extractNodeName(from path: String) -> String? {
        let components = path.components(separatedBy: "/")
        guard let goIndex = components.firstIndex(of: "go"),
              goIndex + 1 < components.count else {
            return nil
        }
        return components[goIndex + 1]
    }

    /// Extract username from path like /member/username
    private static func extractUsername(from path: String) -> String? {
        let components = path.components(separatedBy: "/")
        guard let memberIndex = components.firstIndex(of: "member"),
              memberIndex + 1 < components.count else {
            return nil
        }
        return components[memberIndex + 1]
    }

    // MARK: - Navigation Helpers

    /// Get NavigationDestination from URL
    /// - Parameter urlString: URL string
    /// - Returns: Optional NavigationDestination
    static func destination(from urlString: String) -> NavigationDestination? {
        switch parse(urlString) {
        case .topic(let id):
            return .feedDetail(id: id)
        case .member(let username):
            return .userDetail(username: username)
        case .node(let name):
            return .tagDetail(name: name)
        default:
            return nil
        }
    }
}

// MARK: - Navigation Destination

/// Navigation destinations in the app
enum NavigationDestination: Hashable {
    case feedDetail(id: String)
    case userDetail(username: String)
    case tagDetail(name: String)
}

// MARK: - Link Action

/// Represents the action to take when a link is tapped
enum LinkAction {
    case navigateToTopic(id: String)
    case navigateToUser(username: String)
    case navigateToNode(name: String)
    case openInAppBrowser(url: URL)
    case openInSafariViewController(url: URL)
}

/// Determines the appropriate action for a URL based on settings
class LinkHandler {
    /// Determine what action to take for a given URL
    /// - Parameters:
    ///   - url: The URL to handle
    ///   - useBuiltinBrowser: Whether to use the builtin browser for external links
    /// - Returns: The action to take
    static func action(for url: URL, useBuiltinBrowser: Bool) -> LinkAction {
        let result = URLRouter.parse(url.absoluteString)

        switch result {
        case .topic(let id):
            return .navigateToTopic(id: id)
        case .member(let username):
            return .navigateToUser(username: username)
        case .node(let name):
            return .navigateToNode(name: name)
        case .external(let externalUrl), .webview(let externalUrl):
            // When builtin browser is enabled, use InAppBrowser
            // When disabled, use SafariViewController to stay in app
            if useBuiltinBrowser {
                return .openInAppBrowser(url: externalUrl)
            } else {
                return .openInSafariViewController(url: externalUrl)
            }
        case .invalid:
            return .openInSafariViewController(url: url)
        }
    }
}

// MARK: - URL Testing Helpers

#if DEBUG
extension URLRouter {
    /// Test URL parsing (for debugging)
    static func test() {
        let testCases = [
            "https://www.v2ex.com/t/123456",
            "https://v2ex.com/t/123456#reply123",
            "/t/123456",
            "https://www.v2ex.com/go/swift",
            "/go/swift",
            "https://www.v2ex.com/member/livid",
            "/member/livid",
            "https://www.google.com",
            "https://www.v2ex.com/about"
        ]

        for testCase in testCases {
            let result = parse(testCase)
            print("URL: \(testCase) -> \(result)")
        }
    }
}
#endif
