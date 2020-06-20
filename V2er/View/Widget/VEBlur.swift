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
    let style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
