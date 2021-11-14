//
//  VisualEffectBlur.swift
//  V2er
//
//  Created by Seth on 2020/6/15.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

//import Foundation
import SwiftUI

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
    
    // mark: bug here
//    var blurStyle: UIBlurEffect.Style = .systemThinMaterial
//        var vibrancyStyle: UIVibrancyEffectStyle = .label
//
//        func makeUIView(context: Context) -> UIVisualEffectView {
//            let effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blurStyle), style: vibrancyStyle)
//            let effectView = UIVisualEffectView(effect: effect)
//            return effectView
//        }
//
//        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
//            uiView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blurStyle), style: vibrancyStyle)
//        }
    
}
