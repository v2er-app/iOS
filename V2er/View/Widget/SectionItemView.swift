//
//  SectionItemView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

fileprivate let paddingH: CGFloat = 15

struct SectionItemView: View {
    let title: String
    let icon: String
    var showDivider: Bool = true

    init(_ title: String,
         icon: String = .empty,
         showDivider: Bool = true) {
        self.title = title
        self.icon = icon
        self.showDivider = showDivider
    }

    var body: some View {
        SectionView(title, icon: icon, showDivider: showDivider) {
            Image(systemName: "chevron.right")
                .font(.body.weight(.regular))
                .foregroundColor(.gray)
                .padding(.trailing, paddingH)
        }
    }
}

struct SectionView<Content: View>: View {
    let content: Content
    let title: String
    var showDivider: Bool = true
    let icon: String

    init(_ title: String,
         icon: String = .empty,
         showDivider: Bool = true,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.showDivider = showDivider
        self.content = content()
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .padding(.leading, paddingH)
                .padding(.trailing, icon.isEmpty ? 0 : 5)
                .foregroundColor(.tintColor)
            HStack {
                Text(title)
                Spacer()
                content
                    .padding(.trailing, paddingH)
            }
            .padding(.vertical, 17)
            .divider(showDivider ? 0.8 : 0.0)
        }
        .background(.white)
    }
}
