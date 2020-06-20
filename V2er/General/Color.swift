//
//  Color.swift
//  V2er
//
//  Created by Seth on 2020/6/20.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

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

extension Color {
    public init(_ hex: Int, a: CGFloat = 1.0) {
        self.init(UIColor(hex: hex, alpha: a))
    }
}

struct Color_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Color(0xFBFBFB, a: 1).frame(width: 100, height: 100)
            Color(0x00FF00, a: 0.2).frame(width: 100, height: 100)
        }
        
    }
}
