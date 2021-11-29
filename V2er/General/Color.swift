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
    
    public static let border = hex(0xE8E8E8, alpha: 0.8)
    static let lightGray = hex(0xF5F5F5)
    static let almostClear = hex(0xFFFFFF, alpha: 0.000001)
    static let debugColor = hex(0xFF0000, alpha: 0.1)
//    static let bodyText = hex(0x555555)
    static let bodyText = hex(0x000000, alpha: 0.75)
    static let tintColor = hex(0x383838)
    static let bgColor = hex(0xE2E2E2, alpha: 0.8)
    static let itemBg: Color = .white
    static let dim = hex(0x000000, alpha: 0.6)
//    static let url = hex(0x60c2d4)
    static let url = hex(0x778087)

    public var uiColor: UIColor {
        return UIColor(self)
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



struct Color_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color.hex(0xFBFBFB).frame(width: 100, height: 100)
            Color.hex(0x00FF00, alpha: 0.2).frame(width: 100, height: 100)
            Color.hex(0xFF00FF).frame(width: 100, height: 100)
            Color.tintColor.frame(width: 100, height: 100)
            Color.lightGray.frame(width: 100, height: 100)
            Color.border.frame(width: 100, height: 100).opacity(0.5)
        }
        
    }
}
