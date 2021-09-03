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
            .font(style == .normal ? .headline : .subheadline)
            .fontWeight(.heavy)
            .foregroundColor(.bodyText)
            .padding(.vertical, 8)
            .padding(.horizontal, style == .normal ? 2 : 8)
            .background {
                if style == .small {
                    HStack (spacing: 0) {
                        RoundedRectangle(cornerRadius: 99)
                            .foregroundColor(.tintColor.opacity(0.9))
                            .padding(.vertical, 8)
                            .frame(width: 3)
                        Spacer()
                    }
                }
            }
            .greedyWidth(.leading)
            .debug()
    }
}

struct SectionTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitleView("Title")
    }
}
