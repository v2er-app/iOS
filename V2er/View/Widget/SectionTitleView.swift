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
    
    public init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.body)
            .fontWeight(.heavy)
            .foregroundColor(.bodyText)
            .padding(8)
            .background {
                HStack (spacing: 0) {
                    RoundedRectangle(cornerRadius: 99)
                        .foregroundColor(.tintColor.opacity(0.9))
                        .padding(.vertical, 8)
                        .frame(width: 3)
                    Spacer()
                }
            }
    }
}

struct SectionTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitleView("Title")
    }
}
