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
    let hideDivider: Bool
    
    init(paddingH: CGFloat = 2, hideDivider: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.paddingH = paddingH
        self.hideDivider = hideDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topSafeAreaInset().top)
            HStack(alignment: .center, spacing: 0) {
                self.content
            }
            Divider()
                .opacity(hideDivider ? 0.0 : 1.0)
        }
        .greedyWidth()
        .padding(.horizontal, self.paddingH)
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
