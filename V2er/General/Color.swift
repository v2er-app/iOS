//
//  Color.swift
//  V2er
//
//  Created by Seth on 2020/6/20.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    private init(_ hex: Int, a: CGFloat = 1.0) {
        self.init(UIColor(hex: hex, alpha: a))
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

    // MARK: - Semantic Colors (UIKit-backed, auto-adapt to light/dark/accessibility)

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

    // MARK: - Deprecated Aliases (use semantic names above)

    @available(*, deprecated, renamed: "separator")
    public static let border = Color(.separator)

    @available(*, deprecated, message: "Use Color(.systemGray6) directly")
    public static let lightGray = Color(.systemGray6)

    public static let debugColor = hex(0xFF0000, alpha: 0.1)

    @available(*, deprecated, renamed: "primaryText")
    public static let bodyText = Color(.label)

    @available(*, deprecated, renamed: "tint")
    public static let tintColor = Color.accentColor

    @available(*, deprecated, renamed: "background")
    public static let bgColor = Color(.systemBackground)

    @available(*, deprecated, renamed: "itemBackground")
    public static let itemBg = Color(.secondarySystemGroupedBackground)

    @available(*, deprecated, message: "Use Color(.quaternaryLabel) directly")
    public static let dim = Color(.quaternaryLabel)

    public static let url = Color("URLColor")

    public var uiColor: UIColor {
        return UIColor(self)
    }
}

// MARK: - Dynamic Color Creation
extension Color {
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

    static func dynamicHex(light: Int, dark: Int, alpha: CGFloat = 1.0) -> Color {
        return dynamic(
            light: Color.hex(light, alpha: alpha),
            dark: Color.hex(dark, alpha: alpha)
        )
    }
}

extension UIColor {
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
extension UIImage {
    /// Returns the most vibrant (saturated + bright) color from the image,
    /// darkened for use as a banner background with white text.
    /// Falls back to a darkened average if no vibrant pixel is found.
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
        // Darken + boost saturation for readable white text on top
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        base.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: min(s * 1.3, 1), brightness: min(b, 0.4), alpha: 1)
    }
}

// MARK: - Preview
struct Color_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
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

            // Dark Mode Preview
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
