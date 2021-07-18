//
//  NavHostView.swift
//  V2er
//
//  Created by Seth on 2021/7/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NavbarHostView<Content: View>: View {
    let content: Content
    let paddingH: CGFloat
    
    init(paddingH: CGFloat = 2, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.paddingH = paddingH
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topSafeAreaInset().top)
            HStack(alignment: .center, spacing: 0) {
                self.content
            }
            Divider()
                .light()
        }
        .greedyWidth()
        .padding(.horizontal, self.paddingH)
        .background(VEBlur())
    }
}

struct NavHostView_Previews: PreviewProvider {
    static var previews: some View {
        NavbarHostView {
            Text("V2EX")
                .font(.headline)
        }
    }
}
