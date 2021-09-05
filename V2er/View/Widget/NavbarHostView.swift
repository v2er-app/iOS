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
    @State var shouldHideDivider: Bool = false
    
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
                .opacity(shouldHideDivider ? 0.0 : 1.0)
        }
        .greedyWidth()
        .padding(.horizontal, self.paddingH)
    }
    
    func hideDivider(hide: Bool = true) -> some View {
        self.shouldHideDivider = hide
        return self
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
