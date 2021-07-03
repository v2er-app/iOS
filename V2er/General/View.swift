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
    
}


// Custome ViewModifier

struct DebugModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(.red, width: 3)
    }
}
