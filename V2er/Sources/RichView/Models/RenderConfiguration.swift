//
//  RenderConfiguration.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import Foundation

/// Configuration for RichView rendering behavior
public struct RenderConfiguration: Equatable {

    /// Custom stylesheet for fine-grained style control
    public var stylesheet: RenderStylesheet

    /// Whether images should be loaded
    public var enableImages: Bool

    /// Whether code syntax highlighting should be enabled
    public var enableCodeHighlighting: Bool

    /// Crash on unsupported tags in DEBUG builds (default: true)
    public var crashOnUnsupportedTags: Bool

    /// Whether caching should be enabled
    public var enableCaching: Bool

    /// Maximum cache size in MB
    public var maxCacheSize: Int

    /// Image loading quality
    public var imageQuality: ImageQuality

    /// Maximum concurrent image loads
    public var maxConcurrentImageLoads: Int

    public init(
        stylesheet: RenderStylesheet = .default,
        enableImages: Bool = true,
        enableCodeHighlighting: Bool = true,
        crashOnUnsupportedTags: Bool = true,
        enableCaching: Bool = true,
        maxCacheSize: Int = 50,
        imageQuality: ImageQuality = .medium,
        maxConcurrentImageLoads: Int = 3
    ) {
        self.stylesheet = stylesheet
        self.enableImages = enableImages
        self.enableCodeHighlighting = enableCodeHighlighting
        self.crashOnUnsupportedTags = crashOnUnsupportedTags
        self.enableCaching = enableCaching
        self.maxCacheSize = maxCacheSize
        self.imageQuality = imageQuality
        self.maxConcurrentImageLoads = maxConcurrentImageLoads
    }

    /// Image loading quality
    public enum ImageQuality: String, Equatable {
        case low
        case medium
        case high
        case original
    }
}

// MARK: - Presets

extension RenderConfiguration {

    /// Default configuration for topic content
    public static let `default` = RenderConfiguration(
        stylesheet: .default,
        enableImages: true,
        enableCodeHighlighting: true,
        crashOnUnsupportedTags: true,
        enableCaching: true,
        maxCacheSize: 50,
        imageQuality: .medium,
        maxConcurrentImageLoads: 3
    )

    /// Compact configuration for reply content
    public static let compact = RenderConfiguration(
        stylesheet: .compact,
        enableImages: true,
        enableCodeHighlighting: true,
        crashOnUnsupportedTags: true,
        enableCaching: true,
        maxCacheSize: 30,
        imageQuality: .low,
        maxConcurrentImageLoads: 2
    )

    /// Performance-optimized configuration
    public static let performance = RenderConfiguration(
        stylesheet: .compact,
        enableImages: false,
        enableCodeHighlighting: false,
        crashOnUnsupportedTags: false,
        enableCaching: true,
        maxCacheSize: 100,
        imageQuality: .low,
        maxConcurrentImageLoads: 1
    )

    /// Debug configuration
    public static let debug = RenderConfiguration(
        stylesheet: .default,
        enableImages: true,
        enableCodeHighlighting: true,
        crashOnUnsupportedTags: true,
        enableCaching: false,
        maxCacheSize: 0,
        imageQuality: .original,
        maxConcurrentImageLoads: 5
    )
}