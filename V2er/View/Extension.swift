//
//  View.swift
//  V2er
//
//  Created by Seth on 2020/6/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

extension View {
    
    public func safeAreaInsets() -> UIEdgeInsets {
        var result: UIEdgeInsets
        if let insets = UIApplication.shared.windows.first?.safeAreaInsets {
            result = insets
        } else {
            let isIPhoneMini = V2erApp.deviceType == .iPhone12Mini
            let defaultInsetTop = isIPhoneMini ? 50.0 : 47.0
            let defaultInsetBottom = 34.0
            result = UIEdgeInsets.init(top: defaultInsetTop, left: 0,
                                       bottom: defaultInsetBottom, right: 0)
        }
        print("insets: \(result)")
        return result;
    }
    
    public func debug() -> some View {
#if DEBUG
        self.modifier(DebugModifier())
#endif
    }
    
    public func roundedEdge(radius: CGFloat = -1,
                            borderWidth: CGFloat = 0.4,
                            color: Color = Color.gray) -> some View {
        self.modifier(RoundedEdgeModifier(radius: radius,
                                          width: borderWidth, color: color))
    }
    
}

struct DebugModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(.green, width: 3)
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


extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

