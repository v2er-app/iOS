//
//  VisualEffectBlur.swift
//  V2er
//
//  Created by Seth on 2020/6/15.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

#if os(iOS)
struct VEBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial
    var bg: Color = .clear

    func makeUIView(context: Context) -> UIVisualEffectView {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        effectView.backgroundColor = bg.uiColor
        return effectView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
#elseif os(macOS)
struct VEBlur: NSViewRepresentable {
    var bg: Color = .clear

    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.material = .hudWindow
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}
#endif
