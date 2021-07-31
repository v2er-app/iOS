//
//  AvatarView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AvatarView: View {
    var src: String = "avar"
    var size: CGFloat = 48.0
    
    var body: some View {
        Image(src)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .roundedEdge()
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(size: 48)
    }
}
