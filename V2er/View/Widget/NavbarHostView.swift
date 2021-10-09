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
            .greedyWidth()
            Divider()
                .opacity(hideDivider ? 0.0 : 1.0)
        }
        .greedyWidth()
        .padding(.horizontal, self.paddingH)
        .forceClickable()
    }
}

struct NavbarView<TitleView: View>: View {
    @Environment(\.dismiss) var dismiss
    let titleView: TitleView

    init(@ViewBuilder titleView: () -> TitleView) {
        self.titleView = titleView()
    }

    var body: some View {
        NavbarHostView(paddingH: 0, hideDivider: false) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                        .foregroundColor(.tintColor)
                }
                Spacer()
            }
            .greedyWidth()
            .overlay {
                HStack(alignment: .center) {
                    titleView
                }
            }
        }
        .visualBlur()
    }
}

struct NavHostView_Previews: PreviewProvider {
    static var previews: some View {
        NavbarView {
            Text("Title")
                .font(.headline)
        }
    }
}
