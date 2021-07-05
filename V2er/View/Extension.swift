//
//  View.swift
//  V2er
//
//  Created by Seth on 2020/6/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

extension View {
    
    public func safeAreaInsets() -> UIEdgeInsets? {
        let window = UIApplication.shared.windows[0]
        let insets = window.safeAreaInsets
        print("insets.top: \(insets.top)")
        return insets;
    }
    
    public func debug() -> some View {
        self.modifier(DebugModifier())
    }
    
    public func roundedEdge(radius: CGFloat = -1,
                            borderWidth: CGFloat = 0.4,
                            color: Color = Color.gray) -> some View {
        self.modifier(RoundedEdgeModifier(radius: radius,
                                          width: borderWidth, color: color))
    }
    
}


// Custome ViewModifier

struct DebugModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(.red, width: 3)
    }
}

struct RoundedEdgeModifier: ViewModifier {
    var width: CGFloat = 2
    var color: Color = .black
    var cornerRadius: CGFloat = 16.0
    
    init(radius: CGFloat, width: CGFloat, color: Color) {
        self.cornerRadius = radius
        self.width = width
        self.color = color
    }
    
    func body(content: Content) -> some View {
        if cornerRadius == -1 {
            content
                .clipShape(Circle())
                .padding(width)
                .overlay(Circle().stroke(color, lineWidth: width))
            
        } else {
            content
                .cornerRadius(cornerRadius - width)
                .padding(width)
                .background(color)
                .cornerRadius(cornerRadius)
        }
    }
}
