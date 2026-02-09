//
//  Color.swift
//  V2er
//
//  Created by Seth on 2020/6/20.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

#if os(iOS)
typealias PlatformColor = UIColor
typealias PlatformImage = UIImage
typealias PlatformFont = UIFont
#elseif os(macOS)
typealias PlatformColor = NSColor
typealias PlatformImage = NSImage
typealias PlatformFont = NSFont
#endif

extension Color {
    private init(_ hex: Int, a: CGFloat = 1.0) {
        self.init(PlatformColor(hex: hex, alpha: a))
    }

    public static func hex(_ hex: Int, alpha: CGFloat = 1.0) -> Color {
        return Color(hex, a: alpha)
    }

    public static func shape(_ hex: Int, alpha: CGFloat = 1.0) -> some View {
        return Self.hex(hex, alpha: alpha).frame(width: .infinity)
    }

    public func shape() -> some View {
        self.frame(width: .infinity)
    }

    // MARK: - Semantic Colors (auto-adapt to light/dark/accessibility)

    #if os(iOS)
    // Background Colors
    public static let background = Color(.systemBackground)
    public static let secondaryBackground = Color(.secondarySystemBackground)
    public static let tertiaryBackground = Color(.tertiarySystemBackground)
    public static let itemBackground = Color(.secondarySystemGroupedBackground)

    // Text Colors
    public static let primaryText = Color(.label)
    public static let secondaryText = Color(.secondaryLabel)
    public static let tertiaryText = Color(.tertiaryLabel)

    // UI Element Colors
    public static let separator = Color(.separator)
    public static let tint = Color.accentColor
    public static let selection = Color(.systemGray4)

    // Deprecated Aliases
    @available(*, deprecated, renamed: "separator")
    public static let border = Color(.separator)

    @available(*, deprecated, message: "Use Color(.systemGray6) directly")
    public static let lightGray = Color(.systemGray6)
    #else
    // macOS equivalents using NSColor
    public static let background = Color(nsColor: .windowBackgroundColor)
    public static let secondaryBackground = Color(nsColor: .controlBackgroundColor)
    public static let tertiaryBackground = Color(nsColor: .underPageBackgroundColor)
    public static let itemBackground = Color(nsColor: .controlBackgroundColor)

    public static let primaryText = Color(nsColor: .labelColor)
    public static let secondaryText = Color(nsColor: .secondaryLabelColor)
    public static let tertiaryText = Color(nsColor: .tertiaryLabelColor)

    public static let separator = Color(nsColor: .separatorColor)
    public static let tint = Color.accentColor
    public static let selection = Color(nsColor: .selectedContentBackgroundColor)

    public static let border = Color(nsColor: .separatorColor)
    public static let lightGray = Color(nsColor: .controlBackgroundColor)
    #endif

    public static let debugColor = hex(0xFF0000, alpha: 0.1)

    @available(*, deprecated, renamed: "primaryText")
    public static let bodyText = primaryText

    @available(*, deprecated, renamed: "tint")
    public static let tintColor = Color.accentColor

    @available(*, deprecated, renamed: "background")
    public static let bgColor = background

    @available(*, deprecated, renamed: "itemBackground")
    public static let itemBg = itemBackground

    @available(*, deprecated, message: "Use Color(.quaternaryLabel) directly")
    public static let dim = tertiaryText

    public static let url = Color("URLColor")

    #if os(iOS)
    public var uiColor: UIColor {
        return UIColor(self)
    }
    #else
    public var uiColor: NSColor {
        return NSColor(self)
    }
    #endif
}

// MARK: - Dynamic Color Creation
extension Color {
    #if os(iOS)
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    #else
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? NSColor(dark) : NSColor(light)
        })
    }
    #endif

    static func dynamicHex(light: Int, dark: Int, alpha: CGFloat = 1.0) -> Color {
        return dynamic(
            light: Color.hex(light, alpha: alpha),
            dark: Color.hex(dark, alpha: alpha)
        )
    }
}

extension PlatformColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: alpha)
    }
}

// MARK: - Image Color Extraction
#if os(iOS)
extension UIImage {
    var bannerColor: UIColor? {
        guard let cgImage = cgImage else { return nil }

        let width = 16, height = 16
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return nil }

        let ptr = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        var bestColor: UIColor?
        var bestScore: CGFloat = 0

        for i in 0..<(width * height) {
            let o = i * 4
            let r = CGFloat(ptr[o]) / 255, g = CGFloat(ptr[o+1]) / 255, b = CGFloat(ptr[o+2]) / 255
            let color = UIColor(red: r, green: g, blue: b, alpha: 1)
            var h: CGFloat = 0, s: CGFloat = 0, br: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &br, alpha: nil)
            guard br > 0.15 && br < 0.95 else { continue }
            let score = s * br
            if score > bestScore {
                bestScore = score
                bestColor = color
            }
        }

        let base = bestScore > 0.15 ? bestColor! : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        base.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: min(s * 1.3, 1), brightness: min(b, 0.4), alpha: 1)
    }
}
#endif

// MARK: - macOS System Color Compatibility
// Provides UIColor-like system color names on macOS so that
// `Color(.systemGroupedBackground)` etc. compile unchanged.
#if os(macOS)
extension NSColor {
    static var systemBackground: NSColor { .windowBackgroundColor }
    static var secondarySystemBackground: NSColor { .controlBackgroundColor }
    static var tertiarySystemBackground: NSColor { .underPageBackgroundColor }
    static var systemGroupedBackground: NSColor { .windowBackgroundColor }
    static var secondarySystemGroupedBackground: NSColor { .controlBackgroundColor }
    static var systemGray: NSColor { .systemGray }
    static var systemGray2: NSColor { .systemGray }
    static var systemGray3: NSColor { .systemGray }
    static var systemGray4: NSColor { .quaternaryLabelColor }
    static var systemGray5: NSColor { .quinaryLabel }
    static var systemGray6: NSColor { .controlBackgroundColor }
    static var label: NSColor { .labelColor }
    static var secondaryLabel: NSColor { .secondaryLabelColor }
    static var tertiaryLabel: NSColor { .tertiaryLabelColor }
    static var quaternaryLabel: NSColor { .quaternaryLabelColor }
}

extension Color {
    /// Compatibility init so `Color(.systemGroupedBackground)` compiles on macOS
    init(_ nsColor: NSColor) {
        self.init(nsColor: nsColor)
    }
}
#endif

// MARK: - Preview
struct Color_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                Text("Light Mode")
                    .font(.title)
                HStack {
                    Color.background.frame(width: 80, height: 80)
                    Color.secondaryBackground.frame(width: 80, height: 80)
                    Color.itemBackground.frame(width: 80, height: 80)
                }
                HStack {
                    Color.primaryText.frame(width: 80, height: 80)
                    Color.secondaryText.frame(width: 80, height: 80)
                    Color.tint.frame(width: 80, height: 80)
                }
            }
            .padding()
            .background(Color.background)
            .environment(\.colorScheme, .light)

            VStack(spacing: 20) {
                Text("Dark Mode")
                    .font(.title)
                HStack {
                    Color.background.frame(width: 80, height: 80)
                    Color.secondaryBackground.frame(width: 80, height: 80)
                    Color.itemBackground.frame(width: 80, height: 80)
                }
                HStack {
                    Color.primaryText.frame(width: 80, height: 80)
                    Color.secondaryText.frame(width: 80, height: 80)
                    Color.tint.frame(width: 80, height: 80)
                }
            }
            .padding()
            .background(Color.background)
            .environment(\.colorScheme, .dark)
        }
    }
}
