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
    var size: CGFloat = 30.0
    
    var body: some View {
        KFImage.url(URL(string: url ?? .default))
//            .loadDiskFileSynchronously()
            .placeholder { Color.lightGray.frame(width: size, height: size) }
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .cornerBorder()
    }
}

//struct AvatarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AvatarView(size: 48)
//    }
//}
