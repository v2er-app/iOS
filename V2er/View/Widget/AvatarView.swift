//
//  AvatarView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher

struct AvatarView: View {
    var url: String? = ""
    var size: CGFloat = 32

    var body: some View {
        KFImage.url(URL(string: url ?? .default))
            .placeholder { Color(.systemGray6).frame(width: size, height: size) }
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .cornerBorder()
            .accessibilityHidden(true)
    }
}
