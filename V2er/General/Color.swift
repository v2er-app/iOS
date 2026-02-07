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
