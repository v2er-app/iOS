//
//  RichViewCache.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation
import SwiftUI

/// Three-tier caching system for RichView rendering
@available(iOS 18.0, macOS 15.0, *)
public class RichViewCache {

    // MARK: - Singleton

    public static let shared = RichViewCache()

    // MARK: - Cache Instances

    /// Cache for HTML → Markdown conversion
    private let markdownCache: NSCache<NSString, NSString>

    /// Cache for Markdown → AttributedString rendering
    private let attributedStringCache: NSCache<NSString, CachedAttributedString>

    /// Cache for parsed content elements
    private let contentElementsCache: NSCache<NSString, CachedContentElements>

    // MARK: - Statistics

    private var stats = CacheStatistics()
    private let statsLock = NSLock()

    // MARK: - Initialization

    private init() {
        // Markdown cache: 50 MB
        markdownCache = NSCache<NSString, NSString>()
        markdownCache.totalCostLimit = 50 * 1024 * 1024
        markdownCache.countLimit = 200

        // AttributedString cache: 100 MB
        attributedStringCache = NSCache<NSString, CachedAttributedString>()
        attributedStringCache.totalCostLimit = 100 * 1024 * 1024
        attributedStringCache.countLimit = 100

        // Content elements cache: 50 MB
        contentElementsCache = NSCache<NSString, CachedContentElements>()
        contentElementsCache.totalCostLimit = 50 * 1024 * 1024
        contentElementsCache.countLimit = 100

        // Observe memory warnings
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Markdown Cache

    /// Get cached markdown for HTML
    public func getMarkdown(forHTML html: String) -> String? {
        let key = NSString(string: cacheKey(for: html))
        statsLock.lock()
        defer { statsLock.unlock() }

        if let markdown = markdownCache.object(forKey: key) as String? {
            stats.markdownHits += 1
            return markdown
        } else {
            stats.markdownMisses += 1
            return nil
        }
    }

    /// Cache markdown for HTML
    public func setMarkdown(_ markdown: String, forHTML html: String) {
        let key = NSString(string: cacheKey(for: html))
        let value = NSString(string: markdown)
        let cost = markdown.utf8.count
        markdownCache.setObject(value, forKey: key, cost: cost)
    }

    // MARK: - AttributedString Cache

    /// Get cached attributed string for markdown
    public func getAttributedString(forMarkdown markdown: String) -> AttributedString? {
        let key = NSString(string: cacheKey(for: markdown))
        statsLock.lock()
        defer { statsLock.unlock() }

        if let cached = attributedStringCache.object(forKey: key) {
            stats.attributedStringHits += 1
            return cached.attributedString
        } else {
            stats.attributedStringMisses += 1
            return nil
        }
    }

    /// Cache attributed string for markdown
    public func setAttributedString(_ attributedString: AttributedString, forMarkdown markdown: String) {
        let key = NSString(string: cacheKey(for: markdown))
        let cached = CachedAttributedString(attributedString: attributedString)
        let cost = attributedString.characters.count * 16 // Rough estimate
        attributedStringCache.setObject(cached, forKey: key, cost: cost)
    }

    // MARK: - Content Elements Cache

    /// Get cached content elements for HTML
    public func getContentElements(forHTML html: String) -> [ContentElement]? {
        let key = NSString(string: cacheKey(for: html))
        statsLock.lock()
        defer { statsLock.unlock() }

        if let cached = contentElementsCache.object(forKey: key) {
            stats.contentElementsHits += 1
            return cached.elements
        } else {
            stats.contentElementsMisses += 1
            return nil
        }
    }

    /// Cache content elements for HTML
    public func setContentElements(_ elements: [ContentElement], forHTML html: String) {
        let key = NSString(string: cacheKey(for: html))
        let cached = CachedContentElements(elements: elements)
        let cost = elements.count * 1024 // Rough estimate
        contentElementsCache.setObject(cached, forKey: key, cost: cost)
    }

    // MARK: - Cache Management

    /// Clear all caches
    public func clearAll() {
        markdownCache.removeAllObjects()
        attributedStringCache.removeAllObjects()
        contentElementsCache.removeAllObjects()

        statsLock.lock()
        stats = CacheStatistics()
        statsLock.unlock()
    }

    /// Clear markdown cache only
    public func clearMarkdownCache() {
        markdownCache.removeAllObjects()
    }

    /// Clear attributed string cache only
    public func clearAttributedStringCache() {
        attributedStringCache.removeAllObjects()
    }

    /// Clear content elements cache only
    public func clearContentElementsCache() {
        contentElementsCache.removeAllObjects()
    }

    /// Get cache statistics
    public func getStatistics() -> CacheStatistics {
        statsLock.lock()
        defer { statsLock.unlock() }
        return stats
    }

    // MARK: - Memory Management

    @objc private func handleMemoryWarning() {
        // Clear less important caches first
        clearMarkdownCache()

        // If still under pressure, clear more
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.clearAttributedStringCache()
        }
    }

    // MARK: - Helpers

    private func cacheKey(for content: String) -> String {
        // Use SHA256 hash for cache key to handle long content
        let data = Data(content.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Cache Statistics

public struct CacheStatistics {
    public var markdownHits: Int = 0
    public var markdownMisses: Int = 0
    public var attributedStringHits: Int = 0
    public var attributedStringMisses: Int = 0
    public var contentElementsHits: Int = 0
    public var contentElementsMisses: Int = 0

    public var totalHits: Int {
        markdownHits + attributedStringHits + contentElementsHits
    }

    public var totalMisses: Int {
        markdownMisses + attributedStringMisses + contentElementsMisses
    }

    public var hitRate: Double {
        let total = totalHits + totalMisses
        return total > 0 ? Double(totalHits) / Double(total) : 0.0
    }

    public var markdownHitRate: Double {
        let total = markdownHits + markdownMisses
        return total > 0 ? Double(markdownHits) / Double(total) : 0.0
    }

    public var attributedStringHitRate: Double {
        let total = attributedStringHits + attributedStringMisses
        return total > 0 ? Double(attributedStringHits) / Double(total) : 0.0
    }

    public var contentElementsHitRate: Double {
        let total = contentElementsHits + contentElementsMisses
        return total > 0 ? Double(contentElementsHits) / Double(total) : 0.0
    }
}

// MARK: - Cached Values

@available(iOS 18.0, macOS 15.0, *)
private class CachedAttributedString {
    let attributedString: AttributedString
    let timestamp: Date

    init(attributedString: AttributedString) {
        self.attributedString = attributedString
        self.timestamp = Date()
    }
}

private class CachedContentElements {
    let elements: [ContentElement]
    let timestamp: Date

    init(elements: [ContentElement]) {
        self.elements = elements
        self.timestamp = Date()
    }
}

// MARK: - CommonCrypto Import

import CommonCrypto