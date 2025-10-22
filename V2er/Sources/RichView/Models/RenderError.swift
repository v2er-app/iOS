//
//  RenderError.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation

/// Errors that can occur during RichView rendering
public enum RenderError: Error, LocalizedError {
    /// HTML tag that is not supported
    case unsupportedTag(String, context: String)

    /// Invalid HTML structure
    case invalidHTML(String)

    /// Markdown parsing failed
    case markdownParsingFailed(String)

    /// Rendering failed
    case renderingFailed(String)

    /// Cache error
    case cacheError(String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedTag(let tag, let context):
            return "Unsupported HTML tag '\(tag)' found in: \(context)"
        case .invalidHTML(let reason):
            return "Invalid HTML: \(reason)"
        case .markdownParsingFailed(let reason):
            return "Markdown parsing failed: \(reason)"
        case .renderingFailed(let reason):
            return "Rendering failed: \(reason)"
        case .cacheError(let reason):
            return "Cache error: \(reason)"
        }
    }

    /// Assert in DEBUG mode, log in RELEASE mode
    internal static func assertInDebug(_ message: String, crashOnUnsupportedTags: Bool = true) {
        #if DEBUG
        if crashOnUnsupportedTags {
            fatalError("[RichView Error] \(message)")
        } else {
            print("[RichView Error] \(message)")
        }
        #else
        print("[RichView Error] \(message)")
        #endif
    }

    /// Handle unsupported tag based on configuration
    internal static func handleUnsupportedTag(_ tag: String, context: String, crashOnUnsupportedTags: Bool) throws {
        let message = "Unsupported HTML tag '\(tag)' in context: \(context)"

        #if DEBUG
        if crashOnUnsupportedTags {
            fatalError("[RichView] \(message)")
        }
        #endif

        throw RenderError.unsupportedTag(tag, context: context)
    }
}