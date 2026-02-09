//
//  AsyncImageAttachment.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI
import Kingfisher

/// AsyncImage view for RichView with Kingfisher integration
@available(iOS 18.0, macOS 15.0, *)
public struct AsyncImageAttachment: View {

    // MARK: - Properties

    /// Image URL
    let url: URL?

    /// Alt text / description
    let altText: String

    /// Image style configuration
    let style: ImageStyle

    /// Image quality
    let quality: RenderConfiguration.ImageQuality

    /// Threshold below which images are considered "small" (e.g., emojis) and should not be expanded
    private let smallImageThreshold: CGFloat = 100

    /// Loading state
    @State private var isLoading = true

    /// Error state
    @State private var hasError = false

    /// Loaded image size (nil until loaded)
    @State private var loadedImageSize: CGSize?

    // MARK: - Initialization

    public init(
        url: URL?,
        altText: String = "",
        style: ImageStyle,
        quality: RenderConfiguration.ImageQuality = .medium
    ) {
        self.url = url
        self.altText = altText
        self.style = style
        self.quality = quality
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if let url = url {
                KFImage(url)
                    .placeholder { _ in
                        placeholderView
                    }
                    .retry(maxCount: 3, interval: .seconds(2))
                    .onSuccess { result in
                        isLoading = false
                        hasError = false
                        loadedImageSize = result.image.size
                    }
                    .onFailure { _ in
                        isLoading = false
                        hasError = true
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: computedMaxWidth, maxHeight: computedMaxHeight)
                    .cornerRadius(isSmallImage ? 0 : style.cornerRadius)
                    .accessibilityLabel(altText.isEmpty ? "Image" : altText)
            } else {
                errorView
            }
        }
    }

    // MARK: - Computed Properties

    /// Whether this is a small image (like an emoji) that should not be expanded
    private var isSmallImage: Bool {
        guard let size = loadedImageSize else { return false }
        return size.width <= smallImageThreshold && size.height <= smallImageThreshold
    }

    /// Computed max width - use natural size for small images, otherwise use style.maxWidth
    private var computedMaxWidth: CGFloat {
        guard let size = loadedImageSize else { return style.maxWidth }
        if isSmallImage {
            return size.width
        }
        return style.maxWidth
    }

    /// Computed max height - use natural size for small images, otherwise use style.maxHeight
    private var computedMaxHeight: CGFloat {
        guard let size = loadedImageSize else { return style.maxHeight }
        if isSmallImage {
            return size.height
        }
        return style.maxHeight
    }

    // MARK: - Subviews

    private var placeholderView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .frame(width: 40, height: 40)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(style.cornerRadius)
    }

    private var errorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text(altText.isEmpty ? "Image unavailable" : altText)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Text("Tap to retry")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: style.maxWidth, maxHeight: min(style.maxHeight, 200))
        .background(Color.gray.opacity(0.1))
        .cornerRadius(style.cornerRadius)
        .onTapGesture {
            // Retry loading
            isLoading = true
            hasError = false
        }
    }
}

// MARK: - Image Info Model

/// Information about an image in content
public struct ImageInfo: Equatable {
    /// Image URL
    public let url: URL?

    /// Alt text / description
    public let altText: String

    /// Original HTML img tag attributes
    public let attributes: [String: String]

    /// Width if specified
    public var width: CGFloat? {
        if let widthStr = attributes["width"],
           let width = Double(widthStr) {
            return CGFloat(width)
        }
        return nil
    }

    /// Height if specified
    public var height: CGFloat? {
        if let heightStr = attributes["height"],
           let height = Double(heightStr) {
            return CGFloat(height)
        }
        return nil
    }

    public init(url: URL?, altText: String, attributes: [String: String] = [:]) {
        self.url = url
        self.altText = altText
        self.attributes = attributes
    }
}

// MARK: - Image Cache Manager

/// Manager for image caching configuration
public class ImageCacheManager {

    public static let shared = ImageCacheManager()

    private init() {
        configureKingfisher()
    }

    private func configureKingfisher() {
        // Set cache limits
        let cache = KingfisherManager.shared.cache

        // Memory cache: 100 MB
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024

        // Disk cache: 500 MB
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024

        // Cache expiration: 7 days
        cache.diskStorage.config.expiration = .days(7)
    }

    /// Clear all image caches
    public func clearCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }

    /// Clear memory cache only
    public func clearMemoryCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
    }

    /// Get cache size in MB
    public func getCacheSize(completion: @escaping (Double) -> Void) {
        KingfisherManager.shared.cache.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                let sizeInMB = Double(size) / (1024 * 1024)
                completion(sizeInMB)
            case .failure:
                completion(0)
            }
        }
    }
}

// MARK: - Preview

@available(iOS 18.0, macOS 15.0, *)
struct AsyncImageAttachment_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Valid image
            AsyncImageAttachment(
                url: URL(string: "https://www.v2ex.com/static/img/logo.png"),
                altText: "V2EX Logo",
                style: ImageStyle()
            )

            // Invalid URL (error state)
            AsyncImageAttachment(
                url: URL(string: "https://invalid.url/image.png"),
                altText: "Error Image",
                style: ImageStyle()
            )

            // Nil URL
            AsyncImageAttachment(
                url: nil,
                altText: "No URL Provided",
                style: ImageStyle()
            )
        }
        .padding()
    }
}