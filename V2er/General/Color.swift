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
    
    public static let lightGray = hex(0xF5F5F5)
    public static let almostClear = hex(0xFFFFFF, alpha: 0.001)
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
        }
        
    }
}