//
//  SectionTitleView.swift
//  SectionTitleView
//
//  Created by Seth on 2021/7/27.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct SectionTitleView: View {
    var title: String = "Title"
    var style: Style
    enum Style {
        case normal
        case small
    }

    public init(_ title: String, style: Style = .normal) {
        self.title = title
        self.style = style
    }

    var body: some View {
        Text(title)
            .font(style == .normal ? AppFont.sectionTitle : AppFont.sectionTitleSmall)
            .foregroundColor(.primaryText)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, style == .normal ? Spacing.xxs : Spacing.sm)
            .background {
                if style == .small {
                    HStack (spacing: 0) {
                        RoundedRectangle(cornerRadius: CornerRadius.pill)
                            .foregroundColor(Color.accentColor.opacity(0.9))
                            .padding(.vertical, Spacing.sm)
                            .frame(width: 3)
                        Spacer()
                    }
                }
            }
            .greedyWidth(.leading)
            .accessibilityAddTraits(.isHeader)
    }
}

struct SectionTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitleView("Title")
    }
}
