//
//  NewsContentView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsContentView: View {
    var contentInfo: FeedDetailInfo.ContentInfo?
    @Binding var rendered: Bool

    init(_ contentInfo: FeedDetailInfo.ContentInfo?, rendered: Binding<Bool>) {
        self.contentInfo = contentInfo
        self._rendered = rendered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HtmlView(html: contentInfo?.html, imgs: contentInfo?.imgs ?? [], rendered: $rendered)
            Divider()
        }
    }
}


